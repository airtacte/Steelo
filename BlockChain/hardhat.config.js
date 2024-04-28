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
      accounts: ['0x3071f2cc2ab0f2e28536172aebb823c6e1168d3bbc4dc8550d0f8d5851059cec', '0xac7280853c8d130a3b6d35a97411b22b83ba4011b014f57e8d854d583c978ac1', '0x21a80a418ec87c80efaca8efbe8eaf452d69d3370f292d95959884806cf212cc', '0x66635c1c9620fd229777194c0646a613ea490aab052f5b3dad22b5b84c50bda5', '0xd77de4cdde5c72d714bbc53aeb6acf85d28bc626d47ccc61b3f9dafe350b85ba', '0x29d9640194de873bb9286d0eec2af741574c3c3d592d18baad95104721eb64b5', '0x724c1bf1c66a2a31bb8e7be50f6904276a878e73746b492c72c70d095dda7772'],
      timeout: 600000
    }  
    
  },

  
};
