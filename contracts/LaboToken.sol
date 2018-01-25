pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

/**
 * Inherit MintableToken that inherit ERC20 Token
 */
contract LaboToken is MintableToken {
    string public constant name = "LABO Token"; // solium-disable-line uppercase
    string public constant symbol = "LABO"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase
}


