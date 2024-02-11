require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
const { ethers } = require("ethers");

// Convert mnemonic to private keys
function getPrivateKeys(mnemonic) {
    const walletPath = "m/44'/60'/0'/0";
    const wallets = [];
  
    for (let i = 0; i < 10; i++) {
      const wallet = ethers.Wallet.fromMnemonic(mnemonic, `${walletPath}/${i}`);
      wallets.push(wallet.privateKey);
    }
  
    return wallets;
}

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.20",
    networks: {
        polygonZkEvmTestnet: {
            url: process.env.POLYGON_ZKEVM_TESTNET_RPC_URL,
            accounts: process.env.MNEMONIC ? getPrivateKeys(process.env.MNEMONIC) : [],
            chainId: parseInt(process.env.POLYGON_ZKEVM_TESTNET_CHAIN_ID || 1422),
        },
    },
    paths: {
        sources: "./contracts", // Adjusted based on the project structure
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts",
    },
    external: {
        contracts: [
            {
                artifact: "./artifacts/contracts/ExternalContract.sol/ExternalContract.json",
                address: "0xYourContractAddress",
            },
        ],
    },
    // rest of your config...
};

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
                [1422]: {
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