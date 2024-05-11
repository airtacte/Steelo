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
	      '0xf30f17dc44b11105a07408f97745772982043d74c45c1c844e072d0956223d1b', 
	      '0x7f9ffcb2e863bb74eb084fcc2d9aa37ceeb4cc056d1a91373177e734a2e38696', 
	      '0x7146f53aae1d853b3db23a9c46aecf7d86bef7ffb7ae533a3aad22c4e9252881', 
	      '0x41d13d4f990bd5445e5b63f4f388843e40af7e7f2abc454587879dc0de38a64e', 
	      '0x6f1e9ad6edde33a4c2416b1507813e9854a049deaa3f45782ffd74083f834011', 
	      '0xada46c2ff977ad9e58d17d12b5bd5ffd8496b7a19a12674071054efc708364fd', 
	      '0xd0e1a7833943c490a528640e39ea68e7dbab5e978bdb90d7cc3eca181622046f', 
	      '0x923079fab804015a829c1aaeeac57cb44a2162ade97f11ee002e15ffdca72596', 
	      '0x2d7f6df0029e0350ebc3922853b56d8739c66381aab46fd2c44c3664c88aad25', 
	      '0x71ee9dc5db1f01f6f47b8965839358c63e40cbf73543fa6da6a5b86e0a6dd2f2'
      ],
      timeout: 600000
    }  
    
  },

  
};
