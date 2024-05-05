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
      accounts: ['0xe682c5fca7d5e596291cdcb6b43a3b936f82b624058f1c6f588012f4f108dccd', '0xd6f2c27fc38c568ae1930e346feb0120af8b51e84878eb43fee9fc78f5394158', '0xd853ed6801e35644ae1580a029c9982be76c48a46c2f27beb36f9fc5d2abc03b', '0x47aed1d47866254c6d2cd013a558b962366a8fadaf260d28b0c9f4750bc5ab6d', '0x22c33a5ec5508671053474d0f14e3382aea77dcea77936a5867fdf0d581e3254', '0xe41b716e73b5f25e8365e14c708a84d7e24301d9a143586fbb2ab38fea66196f', '0x0eca62450ee7b921ffe9181cd22e85fbc17969a88b304e05e39eee94b9860259', '0x7f7d6a682ae96d9393b6bbef1d3dcc801b8e5e0141905c68458b0b73bb2e5430', '0xe8ff5c040c9ea6a64497e69123afb72769b24fc320f5c1c65f57b19645a2c717', '0xaf84dea2f8a68ba5300e504c1d1e897f8e5ac447fcd2225c05a42ce6aeb4282b'],
      timeout: 600000
    }  
    
  },

  
};
