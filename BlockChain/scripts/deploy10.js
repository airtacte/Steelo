/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteelo3Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0xB23D3b12616B0A9665156e93afcb7A5F3A2E9A40";
    console.log("diamondAddress", diamondAddress);

    const STEELO3Facet = await ethers.getContractFactory('STEELO3Facet')
    const steelo3Facet = await STEELO3Facet.deploy()

    console.log('Deployed steelo3Facet to ', steelo3Facet.address)

    let addresses = [];
    addresses.push(steelo3Facet.address)
    let selectors = getSelectors(steelo3Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steelo3Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steelo3Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steelo3Facet Added To Diamond");
    return steelo3Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteelo3Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteelo3Facet = deploySteelo3Facet
