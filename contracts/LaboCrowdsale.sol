pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "./LaboToken.sol";

/**
 * @title LaboCrowdsale
 * with:
 * CappedCrowdsale - sets a max boundary for raised funds
 * RefundableCrowdsale - set a min goal to be reached and refund if it's not met
 */
contract LaboCrowdsale is Crowdsale, CappedCrowdsale, RefundableCrowdsale {
    using SafeMath for uint256;

    /**
     * Token exchange rates & max/min caps for each sale term
     * exchange rates of LABO token & ETH.
     */
    uint256 constant RATE_PRE_SALE = 1200;
    uint256 constant RATE_WEEK_1 = 1140;
    uint256 constant RATE_WEEK_2 = 1090;
    uint256 constant MIN_WEI_PRE_SALE = 30 ether;
    uint256 constant MIN_WEI_ON_SALE = 0.01 ether;
    uint256 constant MAX_WEI_PRE_SALE = 150 ether;
    uint256 constant MAX_WEI_ON_SALE = 100 ether;

    // class variables
    uint256 public startTime;
    uint256 public endTime;
    uint256 public rate;
    uint256 public goal;
    uint256 public cap;
    address public wallet;
    uint256 public totalSupply;

    /** LaboCrowdsale constructor
     */
    function LaboCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _goal, uint256 _cap, address _wallet, uint256 _totalSupply) public
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    {
        require(_goal <= _cap);

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        goal = _goal;
        cap = _cap;
        wallet = _wallet;
        totalSupply = _totalSupply;
    }


    /** overriding Crowdsale#createTokenContract to change token to LaboToken.
     */
    function createTokenContract() internal returns (MintableToken) {
        return new LaboToken();
    }

    /** overriding CappedCrowdsale#validPurchase to add extra token cap logic
     *  @return true if investors can buy at the moment
     */
    function validPurchase() internal constant returns (bool) {
        bool withinTokenCap = token.totalSupply().add(msg.value.mul(getRate())) <= cap;
        return super.validPurchase() && withinTokenCap;
    }

    /** overriding CappedCrowdsale#hasEnded to add token cap logic
     *  @return true if crowdsale event has ended
     */
    function hasEnded() public constant returns (bool) {
        bool tokenCapReached = token.totalSupply() >= cap;
        return super.hasEnded() || tokenCapReached;
    }

    /** RefundableCrowdsale finalization
     *  - To store remaining LABO tokens.
     *  - To minting unfinished due to the consensus algorithm.
     */
    function finalization() internal {
        uint256 remaining = cap.sub(token.totalSupply());

        if (remaining > 0) {
            token.mint(wallet, remaining);
        }

        // change LaboToken owner to LaboFunder.
        token.transferOwnership(wallet);

        // From RefundableCrowdsale#finalization
        if (goalReached()) {
            vault.close();
        } else {
            vault.enableRefunds();
        }
    }

    /**
     * overriding Crowdsale#buyTokens to rate customizable.
     */
    function buyTokens(address beneficiary) payable public {
        //require(!paused);
        require(beneficiary != 0x0);
        require(validPurchase());
        require(getPeriod()>0);

        uint256 weiAmount = msg.value;
        require(checkLimit(weiAmount));

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(getRate());

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    /**
     * Avoid too big/small buy amount request
     */
    function checkLimit(uint256 _weiAmount) public constant returns (bool) {
        uint8 currentPeriod = getPeriod();
        uint256 weiAmount = _weiAmount;

        if (currentPeriod == 1) {
            return (MIN_WEI_PRE_SALE < weiAmount && weiAmount < MAX_WEI_PRE_SALE);
        } else {
            return (MIN_WEI_ON_SALE < weiAmount && weiAmount < MAX_WEI_ON_SALE);
        }
        return true;
    }

    /**
     * Custom exchange rate for each peiod
     */
    function getRate() public constant returns (uint256) {
        uint256 currentRate = rate;
        uint8 period = getPeriod();

        if (period == 1) {
            currentRate = RATE_PRE_SALE;
        } else if (period == 2) {
            currentRate = RATE_WEEK_1;
        } else if (period == 3){
            currentRate = RATE_WEEK_2;
        } else {
            currentRate = rate;
        }
        return currentRate;
    }

    /**
     * `now` alias is current `block.timestamp` instead of `block.number`
     * ref - https://github.com/OpenZeppelin/zeppelin-solidity/issues/350
     *
     * returns: {1: PRE_SALE, 2: WEEK_1, 3: WEEK_2, 0: Others}
     */
    function getPeriod() internal constant returns (uint8) {
        uint256 week1EndTime = startTime + 86400 * 3; // week 1 is 3 days
        uint256 week2EndTime = startTime + 86400 * 6; // week 2 is 3 days

        if (startTime <= now && now <= week1EndTime){
            return 1;
        } else if (week1EndTime <= now && now <= week2EndTime){
            return 2;
        } else if (week2EndTime <= now && now <= endTime){
            return 3;
        }
        return 0;
    }


}

