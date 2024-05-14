/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteez2Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x7a0867211f190F616A3aBDFB0B000C5C2955029F";
    console.log("diamondAddress", diamondAddress);

    const STEEZ2Facet = await ethers.getContractFactory('STEEZ2Facet')
    const steez2Facet = await STEEZ2Facet.deploy()

    console.log('Deployed steez2Facet to ', steez2Facet.address)

    let addresses = [];
    addresses.push(steez2Facet.address)
    let selectors = getSelectors(steez2Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steez2Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steez2Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steez2Facet Added To Diamond");
    return steez2Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteez2Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteez2Facet = deploySteez2Facet
