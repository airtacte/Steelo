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
      accounts: ['0xd1bc0a9375a0637c095b3539dd1a894b7b404225fcb8a755b64a8fdfa4ec6697', '0xa611c841ccd06f893278230a1c0c5500bff3e88c9006526582f88ce4c286a8d1', '0x7259a36248c6e3d09a847e82c51ba4dafea04f9c1d3c2e3a176071b656597cb1', '0x42a341c169e640c8d8cd757ddd069be8caa957702c88cefaad5b3fd095b5511c', '0x98955a1cd04cd087cb8c67263c31e8ee3a93c49abe5923a302fe9d4613f06e14', '0xee840624e9350947a2ecc96517350a7d661ed7fb91c8e8bbc1b35f2f899b57e9', '0x0e0848e2149216fa6867c8416f99289c89c6cc5abe0003f531f918bb35fdffda'],
      timeout: 600000
    }  
    
  },

  
};
