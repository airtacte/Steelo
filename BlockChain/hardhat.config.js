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
	      '0x29d1c66b4fc80e8a243c4b9c330507b57a5c8eb290c155de23da1b6307d97943', 
	      '0x2c983f11989201d9045c370d992f6b6b311ffd54ded90086bdc166274cb533ec', 
	      '0xe43ecdb971e91899850cd68e618d67e6bde6fbfe6bb35eabdb52f919962af949', 
	      '0xe0ba108816d370938f023e0fb0a92a0a34d290f504eb042783895025dadf1c45', 
	      '0x9fba1d8be08d5b5a81a00028e6019fb72723ae3c687caaeaa5d768ccd74afc56', 
	      '0x61227036568a0851cd9163e175c3d83e915ecf9a5071d703bc54473d824fd3c1', 
	      '0x56adaff1058c213a9dbbc9992ad16427072cba49e967182ce884ba8fdaa42f22', 
	      '0x92de6ff523ce96dda574e7932d1825417b1673b1f986a7d23a575d84b03758b5', 
	      '0x3708e4995af317322ab7412881dfb22ca972231a6ee8c2741601ed0256770d30', 
	      '0x16152790f5a9f36167215cc62aabe3125a5e8ca1647d6851294d088ef71c16b6'
      ],
      timeout: 600000
    }  
    
  },

  
};
