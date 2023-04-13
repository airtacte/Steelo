require("@nomiclabs/hardhat-ethers");
require("hardhat-deploy");

const ALCHEMY_API_KEY = "jhT3QEajr6JISNWO7O9SZi0fncOm94Vq";
const { ethers } = require("hardhat");
const { Safe, SafeFactory } = require('@safe-global/safe-core-sdk');
const { EthersAdapter } = require('@gnosis.pm/safe-ethers-adapters');

async function initSafe() {
    const provider = ethers.provider;
    const ethAdapter = new EthersAdapter({
        ethers,
        signer: provider.getSigner()
    });

    // Create a new Safe wallet
    const safeFactory = new SafeFactory({
        ethAdapter,
        contractNetworks: {
            [80001]: {
                multiSendAddress: '0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c',
                safeMasterCopyAddress: '0x6851D6fDFAfD08c0295C392436245E5bc78B0185',
                safeProxyFactoryAddress: '0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B'
            }
        }
    });
    const safeTransaction = await safeFactory.deploySafe({
        owners: ['<OWNER_ADDRESS_1>', '<OWNER_ADDRESS_2>', '<OWNER_ADDRESS_3>'],
        threshold: 2
    });
    const safeAddress = await safeTransaction.getAddress();

    // Initialize the Safe instance
    const safe = await Safe.create({
        ethAdapter,
        safeAddress,
        contractNetworks: {
            [80001]: {
                multiSendAddress: '0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c',
                safeMasterCopyAddress: '0x6851D6fDFAfD08c0295C392436245E5bc78B0185',
                safeProxyFactoryAddress: '0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B'
            }
        }
    });

    return safe;
}

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.19",
    networks: {
        mumbai: {
            url: `https://polygon-mumbai.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
            accounts: {
                mnemonic: process.env.MNEMONIC || "",
            },
            chainId: 80001,
        },
        // Add ZkEVM network configuration here when needed
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts",
    },
    external: {
        contracts: [],
    },
    ipfs: {
        gateway: "https://ipfs.io/ipfs",
    },
};

module.exports.initSafe = initSafe;