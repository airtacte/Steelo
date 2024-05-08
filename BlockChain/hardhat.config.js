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
	      '0xf28f7b737e207d5a4973f3bbe15df43c670e9bbf54341ac184df6eaca80058bf', 
	      '0xd5dd386899e562341bcc7ca6c6eabfdc10239d9160b401ddf900a10d42c7adff', 
	      '0x1b183d788a7c98c88214d9ac24c626574148cbd8667a8e242e96e43b9ed41a70', 
	      '0x37c1369435e6c48877cc5c19dd9cf5477fc43f70de9c569663a984e45e9f8c02', 
	      '0x20a668ab32292222e3fe0df59db59f62754e07958e6010d52da0067d0ce83129', 
	      '0x73c230bba4c8ec6d312a3a341cc40c06d115c761c3681b15980dafd6240b81ed', 
	      '0x2a9606f61d1f3943e1beb0994016358256158b4690b2b224407b0f459e7014ad', 
	      '0xd22ad012aec60e1df4dedf2a5c3a9b7a9b46ed7c17ccf7c3736cb7a3a289f4b1', 
	      '0xed71677fd6d2ec1cfbe363c19507bc891986f797c1077cea3e0b2deffe6b8dc5', 
	      '0x3f87ed4257a2ad54fbf883516f5ba0e1a6efd4da7686031c9ea8bef1f5f1ea42'
      ],
      timeout: 600000
    }  
    
  },

  
};
