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
	      '0x786b8ef3be58d610b7742f48ea7d62d69082266d28ad8533a138d1d8c02afbaf', 
	      '0x20dd7768582ac5736353e52f02e31e8d2d1842bc966a0e637ac910784e9d4e2a', 
	      '0x5a2517f878f3141eafcb17dd616f70a94caebab1802939686e5a8021fff0d52f', 
	      '0xd89cd0d6ed14dcc1765818f94d454602281817a9b0da3eb188b79a35a0f2133d', 
	      '0x02f88b205be6d09dd07d688981ae7eb5af4245459137c3662c7a7bc47182129a', 
	      '0x7efac9b5731b4f836d2830186804c46b340f2482627e854b20267c623a944393', 
	      '0xad1887507be5e5c46ba6544e20f1e0ce5aea09e5533ccac5725eafe259d2224a', 
	      '0x56f7a3efa86d8876ab967391171eeed779d053efa66e911c7f7ea238592e660c', 
	      '0x8c649923ecffda1fcbfff6ea2ec1e9578e8433146401edbd9383a55eb330f26f', 
	      '0xafd08e0a5598232d668517052332bc5051c76cfd348b3806df02474b8e25f253'
      ],
      timeout: 600000
    }  
    
  },

  
};
