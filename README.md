# ICO Contracts
[![LABO](https://laboproj.io/wp-content/uploads/2017/12/logo_ver04.png)](https://laboproj.io)  
The ICO contracts of [LABO project](https://laboproj.io).
Let me know from our social channels if you have any questions.

# Usage
1. `git clone https://github.com/LaboProject/ico-contracts.git`
1. `cd ico-contracts`
1. `npm install zeppelin-solidity truffle-hdwallet-provider`
1. `truffle develop`

# Deployment
You shold change following values:
 - `gas` and `gasPrice` adjusted to the network you use.
 - startTimestamp

## Using private net(geth)
Prerequisite: geth, MIST or EtherumWallet.  
In case of MAC.

1. `cd config`
1. `mkdir datadir`
1. `geth init private.genesis.json --datadir ./datadir/`
1. Run private net.

        geth --datadir ./datadir --networkid 10 --ipcpath /Users/USERNAME/Library/Ethereum/geth.ipc \
        --rpc --rpcaddr "localhost" --rpcport "8545" --rpccorsdomain "*" --mine --minerthreads 4 --unlock 0,1 \
        console 2>> /tmp/geth.log

# License
- [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.txt)

