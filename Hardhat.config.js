require("@nomiclabs/hardhat-ethers");
require("hardhat-deploy");

const ALCHEMY_API_KEY = "jhT3QEajr6JISNWO7O9SZi0fncOm94Vq";

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
      chainId: 137,
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
