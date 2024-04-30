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
      accounts: ['0x35f3261cc418b10d894f0c73a5d84412fc23c421a0aa4558de1218c271259afd', '0xf13c0c0592506c0fdcdf891ad8be34b39e616fa84d2e3f44193421f2e1027ee1', '0x91ae927e21659ba304ad827031c59d902877b2b3c9a2ce62c41eaabeae418404', '0xc472438547ad9a8f1849d3a6eb5667772bd6f55a1959d58e23d10134d31f0d08', '0xc678c2bf1129341c8f9d116b27ae7f81742fd145a0b2238ad9e8804d7219be31', '0x9b9c898a9b42cd98657d981e50bb3111cc7b2c2c386d28fc35ecce7feb020174', '0xc8332dc5a2c769ad8dcf6e882f9200167146e2653c641c987355e1b64f31eec5'],
      timeout: 600000
    }  
    
  },

  
};
