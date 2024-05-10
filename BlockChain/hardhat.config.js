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
	      '0x536dbab649c9547bcc0fb30ea64bc86a5d917c5a4d10e0f938d733f0de41ef5f', 
	      '0xb04245755c964b938e693c3c6cbc375a70ea886b8242b79b95d9de6b2c6863ad', 
	      '0x824d383e9e44035350ba3775214bbe6553f2082fe86cffe47021455eb51ad8b2', 
	      '0x98eb287885e299820c88c1b7d81758b15740dbd5d5a8d778d5ae4dee7b820d44', 
	      '0x3c9f6c62f378524a07c8f8539ecae8f08d6b81d9002e3c5c75a7c9f96da6ac7d', 
	      '0xf58753629664bfebfb37e0a2413816ff1d44d70ab380536669f2664b94f25e6c', 
	      '0xa496c95ba8b75d4d5dc34778947ca38313d536a05e100099c3733a5c3ba2892c', 
	      '0xdefbc3f8bb32989797a9cab846824c841638b6804cb1a34b066ce03c93073549', 
	      '0xb3823df5c223f921ae255a547e7ba02b631a19312667e593006ac838a79519c9', 
	      '0xd481ebfa674a6324a83d0a9a380ff293b21b0c690dd78cb4debc675d4b110c0d'
      ],
      timeout: 600000
    }  
    
  },

  
};
