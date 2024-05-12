/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteez8Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0xb0CE2464219c79DAE8fC681197C0ceCF0AcDaa04";
    console.log("diamondAddress", diamondAddress);

    const STEEZ8Facet = await ethers.getContractFactory('STEEZ8Facet')
    const steez8Facet = await STEEZ8Facet.deploy()

    console.log('Deployed steez8Facet to ', steez8Facet.address)

    let addresses = [];
    addresses.push(steez8Facet.address)
    let selectors = getSelectors(steez8Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steez8Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steez8Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steez8Facet Added To Diamond");
    return steez8Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteez8Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteez8Facet = deploySteez8Facet
