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
	      '0x9d4dfbb796ca7e8965146326d454805c06f9c275f8d20fbfa3c2e8bc4440913b', 
	      '0x2c565b7f3bb913d02751ff3d3e676e4e096da86289317b59a73511be3e223e68', 
	      '0x87e611395abeb87e31173e7c04fa81605d86bad8b542026cf03797376e9f77a8', 
	      '0x7d49cedb0c4e3260986e17624bd1933b63d8643729016a5bf552efe55ba474bc', 
	      '0xcb8e95a97f3b46af3b2810d5cce95fb6254ee65b59c7f2b9094814ba41a5bb5b', 
	      '0x7a067fde78ecdb808a33490e27a1470c685a91f2e3e39ae17ca15abe9afe4062', 
	      '0x057b77233336b9dc13fe3e1704df181c61f25c5a70aabec00a10abe5f7d56c24', 
	      '0x270593d2c4b73dafc01e548900753f94c1e88cbb60362951f141035419df43d3', 
	      '0x01437b8d01ab6252ea9f0afee41e8ace0deec8d68a875ed82dfc4c752d262204', 
	      '0x343a7d7271db006180e6eb6f4472edb69b330788577120cc1c04d3381cc182df'
      ],
      timeout: 600000
    }  
    
  },

  
};
