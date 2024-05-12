/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteelo4Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0xb0CE2464219c79DAE8fC681197C0ceCF0AcDaa04";
    console.log("diamondAddress", diamondAddress);

    const STEELO4Facet = await ethers.getContractFactory('STEELO4Facet')
    const steelo4Facet = await STEELO4Facet.deploy()

    console.log('Deployed steelo4Facet to ', steelo4Facet.address)

    let addresses = [];
    addresses.push(steelo4Facet.address)
    let selectors = getSelectors(steelo4Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steelo4Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steelo4Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steelo4Facet Added To Diamond");
    return steelo4Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteelo4Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteelo4Facet = deploySteelo4Facet
