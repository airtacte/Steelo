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
      accounts: [
	      '0x689ce979a00d57d296898cb36599d176d616a68f781deefa20066aab2ef608ed', 
	      '0x68f2dff25d13aa1112989aeb6395680bd401ee9a6c5388884f18dd118f23bfbf', 
	      '0x8183b2aa901001e8f4005445ed589ceb72d89d7af9aaad823e65cafd66a3006a', 
	      '0xf85bdfe3b0ae2421607948fdc60110fb27978a1704e04f5b6db7e8ab202b887a', 
	      '0xf901c429ea0d7fd4566ae867d7bf44afb32bd0d73b568b1247fb5586a7ca7559', 
	      '0x977b21e5685713f6e19250313ec648f357373e1b0171f067fa6def743acbe192', 
	      '0x363cef3e569f971f2360fcd0797059527840049a01b02d1b3d0ae5611b677cd9', 
	      '0x85157e40af950a5547cc6b8716615b7bfde8b3330bb72e6355f9266dee4c554b', 
	      '0x3c826071ff72468341851f889a1af87f1dbac473db5623dc61d4b67f6c664499', 
	      '0xe64cde756e51eeab423b3d011f8986ff9e2aa509eb84f239d9dbda4c55df6dd1'
      ],
      timeout: 600000
    }  
    
  },

  
};
