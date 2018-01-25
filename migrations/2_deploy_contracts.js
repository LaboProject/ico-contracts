const fs = require('fs');

const LaboToken = artifacts.require('LaboToken.sol')
const LaboCrowdsale = artifacts.require('LaboCrowdsale.sol');
const crowdsaleParams = JSON.parse(fs.readFileSync('../config/Crowdsale.json', 'utf8'));

/**
 * To use synchronous request - web3.eth.getBlockNumber()
 * avoid unexpected null reference
 *
const Promise = require('bluebird');
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider(Web3.currentProvider));
if (typeof web3.eth.getAccountsPromise === 'undefined') {
    Promise.promisifyAll(web3.eth, { suffix: 'Promise' });
}
*/

function e(i){ // ether unit
    return web3.toWei(i, 'ether');
}
function l(i){ // labo unit
    return new web3.BigNumber(web3.toWei(i, 'ether'));
}

module.exports = function deployContracts(deployer, network, accounts) {
    //const startTime = web3.eth.getBlock(web3.eth.getBlockNumber((err, res) => {})).timestamp + 1;
    //const startTime = web3.eth.getBlock(web3.eth.blockNumber).timestamp + 1;
    const startTime = crowdsaleParams.startTimestamp;
    const endTime = startTime + crowdsaleParams.duration;
    const rate = crowdsaleParams.rate;
    const goal = e(crowdsaleParams.goal);
    const cap = l(crowdsaleParams.cap);
    //const owner = accounts[0];
    const owner = crowdsaleParams.owner;
    const initialSupply = crowdsaleParams.initialSupply;

    deployer.deploy(LaboToken).then(() => {
        return deployer.deploy(LaboCrowdsale, startTime, endTime, rate, goal, cap, owner, initialSupply);
    });
};

