var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = process.env.ROPSTEN_MNEMONIC;
var accessToken = process.env.INFURA_ACCESS_TOKEN;

module.exports = {
    networks: {
        live: {
            network_id: '*',
            host: "localhost",
            port: 8545,
            gas: 210000
        },
        develop: {
            network_id: '*',
            host: "localhost",
            port: 9545,
            gasLimit: 6721975,
            gasPrice: 100000000000
        },
        testrpc: {
            network_id: '*',
            host: "localhost",
            port: 8545,
            gasLimit:6721975, // should be big for test
            gasPrice: 100000000000 // should be big for test
        },
        ropsten: {
            network_id: '*',
            provider: function() {
                return new HDWalletProvider(
                    mnemonic,
                    "https://ropsten.infura.io/" + accessToken
                );
            },
            gasLimit: 4000000,
            gasPrice: 100000000
        },
    }
};
