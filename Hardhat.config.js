require("@nomiclabs/hardhat-ethers");
require("dotenv").config(); // Ensure you have this package installed for environment variables

// This is removed from the global scope of the config file to prevent HH9 errors
// const { ethers } = require("hardhat");
// const { Safe, SafeFactory } = require("@safe-global/safe-core-sdk");
// const { EthersAdapter } = require("@gnosis.pm/safe-ethers-adapters");

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

// Moved inside a Hardhat task to ensure it's correctly scoped and HRE is available
task("initSafe", "Initializes a Gnosis Safe with given owners and threshold")
    .addParam("owners", "The owners of the Safe")
    .addParam("threshold", "The threshold for the Safe")
    .setAction(async ({ owners, threshold }, { ethers }) => {
        const { Safe, SafeFactory } = require("@safe-global/safe-core-sdk");
        const { EthersAdapter } = require("@gnosis.pm/safe-ethers-adapters");

        const provider = ethers.provider;
        const ethAdapter = new EthersAdapter({
            ethers,
            signer: provider.getSigner()
        });

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
            owners: owners.split(","), // Assuming owners are passed as a comma-separated list
            threshold: parseInt(threshold, 10)
        });

        const safeAddress = await safeTransaction.getAddress();
        console.log(`Safe deployed at: ${safeAddress}`);

        const safe = await Safe.create({
            ethAdapter,
            safeAddress,
            contractNetworks: safeFactory.contractNetworks // Reuse the contractNetworks from safeFactory
        });

        return safe;
    });

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.19",
    networks: {
        polygonZkEvmTestnet: {
            url: process.env.POLYGON_ZKEVM_TESTNET_RPC_URL,
            accounts: {
                mnemonic: process.env.MNEMONIC || "",
            },
            chainId: parseInt(process.env.POLYGON_ZKEVM_TESTNET_CHAIN_ID || 1422),
        },
    },
    paths: {
        sources: "./Contracts", // Adjusted based on the project structure
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