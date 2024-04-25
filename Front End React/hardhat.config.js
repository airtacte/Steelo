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
      accounts: ['0xc0ea7f0cfc96bd577dbcd642e7a5a7065f735069e3edf04f1aba39f0aab2a072', '0x2e69fb85733f03ace9c6bca2872d87b8158bc447ec04af4b4a96a94e7a578e15', '0x10526e887f6e058ad7f77a512f962a9d3427051dc22d5c2e67102e1062871153'],
      timeout: 600000
    }
  }
};
