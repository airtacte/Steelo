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
	      '0x466e3418d765614c0a3f8f7c354956710d3e7ecddfc7015f4ae01e7c1b3d24a4', 
	      '0x42f71490d2504518d5fd30a03d4828389117a55e052baf05dd7f2ac560797c22', 
	      '0xbff9dd2e5e3142df2de15392a6a3e92f5c05680f754928f5ce9975b843da90b6', 
	      '0x9f4203c47e2a8cecc0b0761a6f7de8cff336c2c193c70ffd2cb9e48b3912cce3', 
	      '0xd30779771fc465039b2f6886a873ab0c5f04acaab4b3e8f00d1ec50b5718a415', 
	      '0xff686beb1dd159d99057bedad3646dd563506e4b8d85c0b6daf28266d157fbd3', 
	      '0x10222a318b57439385a99a66125c6da234ddec4259b934901074380b0121435a', 
	      '0x4202f213325c5081f468f03c29757744dc4386bb850b759363bf366fb8108acc', 
	      '0x7642fe6065433440a68ed5f24de1ab9f57701403db912d7b830e6e85a4331d12', 
	      '0xa58fe47b11f66aa73e936138e8e909704eabfd763c2220f46223d8ec7b46554e'
      ],
      timeout: 600000
    }  
    
  },

  
};
