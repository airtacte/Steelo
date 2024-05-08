/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deployVillageFacet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x98d1Bd99A647246d45BE34a6057f6A8Bfe5FFe9F";
    console.log("diamondAddress", diamondAddress);

    const VillageFacet = await ethers.getContractFactory('VillageFacet')
    const villageFacet = await VillageFacet.deploy()

    console.log('Deployed villageFacet to ', villageFacet.address)

    let addresses = [];
    addresses.push(villageFacet.address)
    let selectors = getSelectors(villageFacet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: villageFacet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(villageFacet.address)
    assert.sameMembers(result, selectors)
    console.log("villageFacet Added To Diamond");
    return villageFacet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deployVillageFacet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployVillageFacet = deployVillageFacet
