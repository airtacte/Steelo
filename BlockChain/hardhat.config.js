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
      accounts: ['0x39976dccc78595fc359e17eb8126df621dd89ee21cecc5c359b42f91d95531c4', '0xa68e74d82035b618c708576a4632f08c6482be33781c1f80e99bd42891606d86', '0x8c6634beb6c45130a335a757afe856dfb0227e02203b041972971a34c11f24db', '0x87de2f5a905d6de58a7409567b66d1342021c88c8d5404647a7aad800ed71ac5', '0xc9c0b84eb3cd047843d97c0e7ea5926751d7765fc4cd29e850885333b6a97fb3', '0x5d60fbb311d0832124504fb837faa087269a030740500ddecf72487745cc75ff', '0xdb27855024bafa5b62ba68bccb860cfe5262ffb7a8645f81e53807cf2a8e890c'],
      timeout: 600000
    }  
    
  },

  
};
