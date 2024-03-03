const { getSelectors } = require('./diamond.js');

async function main() {
  const DiamondLoupeFacet = await ethers.getContractFactory("DiamondLoupeFacet");
  const diamondLoupeFacet = await DiamondLoupeFacet.deploy();
  await diamondLoupeFacet.deployed();
  console.log("DiamondLoupeFacet deployed to:", diamondLoupeFacet.address);

  const Diamond = await ethers.getContractFactory("Diamond");
  const diamondCut = [
    {
      facetAddress: diamondLoupeFacet.address,
      action: 0, // Add
      functionSelectors: getSelectors(diamondLoupeFacet) // Automatically get function selectors
    }
  ];
  const args = { owner: "<owner_address>" };
  const diamond = await Diamond.deploy(diamondCut, args);
  await diamond.deployed();
  console.log("Diamond deployed to:", diamond.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});