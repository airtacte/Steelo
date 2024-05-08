/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteez5Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x98d1Bd99A647246d45BE34a6057f6A8Bfe5FFe9F";
    console.log("diamondAddress", diamondAddress);

    const STEEZ5Facet = await ethers.getContractFactory('STEEZ5Facet')
    const steez5Facet = await STEEZ5Facet.deploy()

    console.log('Deployed steez5Facet to ', steez5Facet.address)

    let addresses = [];
    addresses.push(steez5Facet.address)
    let selectors = getSelectors(steez5Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steez5Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steez5Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steez5Facet Added To Diamond");
    return steez5Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteez5Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteez5Facet = deploySteez5Facet
