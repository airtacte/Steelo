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
      url: "HTTP://127.0.0.1:8545",
      accounts: [
	      '0x2b208c48e3f76deac6d05b1284c540b4a45f7b55eb728fcef7fcced5efcef267', 
	      '0x10cb9cf387d093d2171ba13f809c6460a82f7cd893892a3258830cf3049498af', 
	      '0x13ca662be4cd90612106f8a6a15f0ec4edb2145e7b5cb96be0a744bcb412a614', 
	      '0x0648a01470f2ae3a7d5c0e84625a20a2dd503e155080fd43f845914024a2e17b', 
	      '0xcd768153fb3b326accb8f6ad5b191fff4a0f7b5283f932ea3ec66a6d90a9c4cf', 
	      '0x658833a2b7df233abd13e247eb909e05d9c6613d269ec4351f3b1812512428ea', 
	      '0x9021051423102f7c06d25ad301ac3894b6f463c69b8c2182283f90f4bb45db3f', 
	      '0x462961f3cff4c92a5115552a1bdfbc02eed9aa410b9888b50d8dcd1b07a0ef4d', 
	      '0x43a8c6b55e4df91276c89c6830ec1974f0bf1b6c26925965e85150674fb7c656', 
	      '0x0ff306cfef8377999676b148f1089922e783b56f05b0a130e836ab978dc020fe'
      ],
      timeout: 600000
    }  
    
  },

  
};
