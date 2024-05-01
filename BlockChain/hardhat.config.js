require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require('solidity-coverage')
require("hardhat-diamond-abi");
require('hardhat-abi-exporter');
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
  
});

function filterDuplicateFunctions(abiElement, index, fullAbiL, fullyQualifiedName) {
  if (["function", "event"].includes(abiElement.type)) {
    const funcSignature = genSignature(abiElement.name, abiElement.inputs, abiElement.type);
    if (elementSeenSet.has(funcSignature)) {
      return false;
    }
    elementSeenSet.add(funcSignature);
  } else if (abiElement.type === 'event') {

  }

  return true;

}

const elementSeenSet = new Set();
// filter out duplicate function signatures
function genSignature(name, inputs, type) {
  return `${type} ${name}(${inputs.reduce((previous, key) => 
    {
      const comma = previous.length ? ',' : '';
      return previous + comma + key.internalType;
    }, '' )})`;
}



 module.exports = {
  solidity: '0.8.1',
  diamondAbi: {
    name: "steeloDiamond",
    include: ['Facet'],
    strict: true,
    filter: filterDuplicateFunctions,
    
  },
  networks: {
    
    ganache: {
      url: "HTTP://127.0.0.1:7545",
      accounts: ['0x2392f28cb2124884d24b6d0ffb76b2ecc54d632347435faf4c7fc046a3692241', '0x8aafe71d09849e6e204383a7f584bd70e1a63ea31e1d97419e280bdd2af09b33', '0x1e7c32c29325f22f5bd9c57868fb37c05b0bdca182c2ee715c48a1b6d00a51f7', '0x295811e60c3db5e33498614957dc499c9196009c12bdeba4161c2dd200ad612c', '0xdaa7b5606b94549bb56cea3fabed13f49371ffcf6b5c187f6ac26060d597a946', '0x40c6b7b38144db88512b1a966c3a9706c5e5d25a5bafcacb1c5a9650a2405019', '0xeac2e0cf2429d38b6c52c83e01a2df68b17c54ffe36e2a1d713af9fe88d82e06'],
      timeout: 600000
    }  
    
  },

  
};
