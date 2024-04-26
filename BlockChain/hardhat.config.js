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
      accounts: ['0x4d93875b69806f53561d77c893f1b26b4cc565b6049bcef80252e3a8155d995c', '0xa90683908c2292ee1dae065c382d1f73c6788a8a3a4d91ddfdccedbd65f4a072', '0x7858cd882556ba845b42ed9e928cce6b09945b585a4f0ce20f49b13c8ae21844', '0x5efff4ecf0545c626bcbee879f0a6cc5a99f7ae5f80c721a590015099a7c12de', '0x15fbe0a433fc6764fda3253e75f86e350ac3c44c98b3aeeb581c60da5890284d', '0x094ec7d1413a56140a5c9eaf9f811dacb969967debb8f6d0c4b0226076c707fb', '0x6ea333a4fe835ec4bf1b75c96ee9d2dc2c55d547a3f1c44c7c9c96d42c9b1ba3'],
      timeout: 600000
    }  
    
  },

  
};
