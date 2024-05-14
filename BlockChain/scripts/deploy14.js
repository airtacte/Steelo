/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteez6Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x7a0867211f190F616A3aBDFB0B000C5C2955029F";
    console.log("diamondAddress", diamondAddress);

    const STEEZ6Facet = await ethers.getContractFactory('STEEZ6Facet')
    const steez6Facet = await STEEZ6Facet.deploy()

    console.log('Deployed steez6Facet to ', steez6Facet.address)

    let addresses = [];
    addresses.push(steez6Facet.address)
    let selectors = getSelectors(steez6Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steez6Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steez6Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steez6Facet Added To Diamond");
    return steez6Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteez6Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteez6Facet = deploySteez6Facet
