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
      accounts: ['0x00fc378ee657ca97219cd8f1ebb4585ae7e7c24da631c752359858e3b9b00b7c', '0x419d7635215db63e860da8d4b90989a017ceb8e6705819b12a73ec2c48b05059', '0xe3bb30a312e39c0d086178bbabb6d3b899196c7d7565e9a237faa72e5f877f69', '0x51d956d92e16808e6d806bcb81b6bc4709b3f877fd384637643706d4297e9380', '0x59d3e7defeef36caac77a9244aa2283b442c9dd9fd125a13cee76dcd42e87ea3', '0xd7c4c88fdf9158e16b0cd70fd147a7255ecdea636a440ab9b21de4a7aeb2e874', '0x07a17fd6dd65be30c005d9d96758f755722faa76a25bd6684cb71b4dd14bb708'],
      timeout: 600000
    }  
    
  },

  
};
