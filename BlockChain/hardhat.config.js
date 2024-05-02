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
      accounts: ['0xc67d357549c7c5fdd56bac8baaa6cad058086c11da332c4ffc56025edfe0e63c', '0xac2390844b0bf0b4344d19b42be82d15d9e83849aa19953bfba850348007c752', '0xbc32bf5760902331eef4d493ed1547c4bc16fca033e570cf3b0fddc57b26842b', '0x3e579b4cfac4b135aad65cdebb96743b9338c109253887c893d3f676c795dc49', '0x757b47f656295c6f85314e75ab3798211c6002add5b0c1b11ab0c6891fda3d06', '0xff18dc0001d480c649301d789e04092901e9701c7789d5c155e56da09c0d2431', '0x89793db7377c6359740817764526afb32efbc19a70827f63d1bfcad0c4406279'],
      timeout: 600000
    }  
    
  },

  
};
