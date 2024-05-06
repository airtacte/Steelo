require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    ganache: {
      url: "HTTP://127.0.0.1:7545",
      accounts: ['0x138ae41d86f7ef78df7960cef2cf05fca2f4ce793e7be296455215df92f92f8a', '0xbe6319b35fbfe8f0c3e4aeef8edb73fd500dc77d112b1b0dd334955a03152e40', '0x525e9a756bae807bd4ae4d66a4773bfd44166c4e982be5161077ccd542790a9b'],
      timeout: 600000
    }
  }
};
