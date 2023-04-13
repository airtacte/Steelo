const hre = require('hardhat');
const ethers = hre.ethers;

async function main() {
  const [deployer] = await ethers.getSigners();
  const deploySteeloToken = await hre.ethers.getContractFactory('SteeloToken');
  const steeloToken = await deploySteeloToken.deploy();

  await steeloToken.deployed();
  await steeloToken.initializeWithSafe('https://your-base-uri.com/', safe.getAddress());  // Replace with dApp URI

  const safe = await hre.initSafe();

  console.log('SteeloToken deployed to:', steeloToken.address);
  console.log('Safe Multisig Wallet deployed to:', safe.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  // Run using following line in terminal ==> npx hardhat run deploySteeloToken.js --network mumbai