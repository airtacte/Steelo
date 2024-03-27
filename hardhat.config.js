require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

// Define common settings for reuse
const commonCompilerSettings = {
  optimizer: {
    enabled: true,
    runs: 200,
  },
  evmVersion: "istanbul",
};

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.24", // Uniswap-v4
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.8.20", // Uniswap-v4
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.8.19", // Uniswap-v4
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.8.15", // Uniswap-v4
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.8.10", // Lens
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.8.9", // Lido DAO
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.8.4", // Lido DAO
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.8.0", // Uniswap-v4
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.7.6", // Safe Contracts
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.6.12", // Lido DAO
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.6.11", // Lido DAO
        settings: { ...commonCompilerSettings },
      },
      {
        version: "0.4.24", // Lido DAO
        settings: { ...commonCompilerSettings },
      },
    ],
    ignore: [
      "./lib/lido-dao/contracts/0.4.24/**",
      "./lib/lido-dao/contracts/0.6.11/**",
      "./lib/lido-dao/contracts/0.6.12/**",
      "./lib/lido-dao/contracts/0.8.4/**",
    ],
  },
  networks: {
    polygonZkEvmTestnet: {
      url: process.env.POLYGON_ZKEVM_TESTNET_RPC_URL,
      accounts: {
        mnemonic: process.env.MNEMONIC,
      },
      chainId: parseInt(process.env.POLYGON_ZKEVM_TESTNET_CHAIN_ID || 1422),
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  external: {
    contracts: [
      {
        artifact:
          "./artifacts/contracts/ExternalContract.sol/ExternalContract.json",
        address: "0xYourContractAddress",
      },
    ],
  },
  // rest of your config...
};

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// This is removed from the global scope of the config file to prevent HH9 errors
// const { ethers } = require("hardhat");
// const { Safe, SafeFactory } = require("@safe-global/safe-core-sdk");
// const { EthersAdapter } = require("@safe-global/safe-ethers-adapters");

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

task("initSafe", "Initializes a Gnosis Safe with given owners and threshold")
  .addParam("owners", "The owners of the Safe")
  .addParam("threshold", "The threshold for the Safe")
  .setAction(async ({ owners, threshold }, { ethers }) => {
    const { Safe, SafeFactory } = require("@safe-global/safe-core-sdk");
    const { EthersAdapter } = require("@safe-global/safe-ethers-adapters");

    const provider = ethers.provider;
    const ethAdapter = new EthersAdapter({
      ethers,
      signer: provider.getSigner(),
    });

    const safeFactory = new SafeFactory({
      ethAdapter,
      contractNetworks: {
        [1422]: {
          multiSendAddress: "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c",
          safeMasterCopyAddress: "0x6851D6fDFAfD08c0295C392436245E5bc78B0185",
          safeProxyFactoryAddress: "0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B",
        },
      },
    });

    const safeTransaction = await safeFactory.deploySafe({
      owners: owners.split(","), // Assuming owners are passed as a comma-separated list
      threshold: parseInt(threshold, 10),
    });

    const safeAddress = await safeTransaction.getAddress();
    console.log(`Safe deployed at: ${safeAddress}`);

    const safe = await Safe.create({
      ethAdapter,
      safeAddress,
      contractNetworks: safeFactory.contractNetworks, // Reuse the contractNetworks from safeFactory
    });

    return safe;
  });