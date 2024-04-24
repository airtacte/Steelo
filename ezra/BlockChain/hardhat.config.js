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
      accounts: ['0x87df44c374f13be4521249a2f7a262cfb7282e90a9839bf76c59fe808b47f114', '0x31c8e8baf765d8436e3342df22023f5cf1c7d1e8a324f0a8748588fdf57c699d', '0x817916e35d9266148caa8d755988237a1400e0df3f2e1bf1987e1f493cc99bea', '0x03f6a848dca28fa4dbfc5e540893f45838bd26bbf824c03b34a5460dad112a2d', '0xb1f801bfdc28baff9335e279d636a4632f4ab05bf69c62c8f7c31553ee372e84', '0x56e4a669ce7b1d94e8c803717fe64f44e166f53d4b4c83b79f150e69076a4573', '0x62aaa6222ec3561f1c6f122f756add632ff6cd84b0b2390a91e9a06d1df3e19a'],
      timeout: 600000
    }  
    
  },

  
};
