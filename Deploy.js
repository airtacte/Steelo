const hre = require('hardhat');
const ethers = hre.ethers;

async function main() {
  const [deployer] = await ethers.getSigners();

  // Deploy DiamondCutFacet
  const DiamondCutFacet = await hre.ethers.getContractFactory('DiamondCutFacet');
  const diamondCutFacet = await DiamondCutFacet.deploy();
  await diamondCutFacet.deployed();

  // Deploy DiamondLoupeFacet
  const DiamondLoupeFacet = await hre.ethers.getContractFactory('DiamondLoupeFacet');
  const diamondLoupeFacet = await DiamondLoupeFacet.deploy();
  await diamondLoupeFacet.deployed();

  // Deploy CreatorToken
  const CreatorToken = await hre.ethers.getContractFactory('CreatorToken');
  const creatorToken = await CreatorToken.deploy();
  await creatorToken.deployed();

  // Deploy Royalties
  const Royalties = await hre.ethers.getContractFactory('Royalties');
  const royalties = await Royalties.deploy();
  await royalties.deployed();

  // Deploy Diamond
  const Diamond = await hre.ethers.getContractFactory('Diamond');
  const diamond = await Diamond.deploy();
  await diamond.deployed();

  // Initialize diamond with DiamondCutFacet and DiamondLoupeFacet
  await diamond.initialize([diamondCutFacet.address, diamondLoupeFacet.address]);

  // Add CreatorToken and Royalties facets using diamondCut function
  const addCreatorTokenFacet = [
    {
      action: 0, // 0 for adding facet
      facetAddress: creatorToken.address,
      functionSelectors: await creatorToken.getSelectors()
    }
  ];

  const addRoyaltiesFacet = [
    {
      action: 0, // 0 for adding facet
      facetAddress: royalties.address,
      functionSelectors: await royalties.getSelectors()
    }
  ];

  await diamond.diamondCut(addCreatorTokenFacet.concat(addRoyaltiesFacet), deployer.address, '0x');

  // Verify facets and functions using loupe functions
  const allFacets = await diamond.facets();
  console.log('All facets:', allFacets);

  console.log('Diamond deployed to:', diamond.address);
  console.log('DiamondCutFacet deployed to:', diamondCutFacet.address);
  console.log('DiamondLoupeFacet deployed to:', diamondLoupeFacet.address);
  console.log('CreatorToken deployed to:', creatorToken.address);
  console.log('Royalties deployed to:', royalties.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  // Run using following line in terminal ==> npx hardhat run deploySteeloToken.js --network mumbai