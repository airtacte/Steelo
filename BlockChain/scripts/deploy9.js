/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteez3Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x7a0867211f190F616A3aBDFB0B000C5C2955029F";
    console.log("diamondAddress", diamondAddress);

    const STEEZ3Facet = await ethers.getContractFactory('STEEZ3Facet')
    const steez3Facet = await STEEZ3Facet.deploy()

    console.log('Deployed steez3Facet to ', steez3Facet.address)

    let addresses = [];
    addresses.push(steez3Facet.address)
    let selectors = getSelectors(steez3Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steez3Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steez3Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steez3Facet Added To Diamond");
    return steez3Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteez3Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteez3Facet = deploySteez3Facet
