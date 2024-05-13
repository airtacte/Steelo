/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteelo2Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x2Ef4b738e2119DDB78A95Bf075ECd879747660Ff";
    console.log("diamondAddress", diamondAddress);

    const STEELO2Facet = await ethers.getContractFactory('STEELO2Facet')
    const steelo2Facet = await STEELO2Facet.deploy()

    console.log('Deployed steelo2Facet to ', steelo2Facet.address)

    let addresses = [];
    addresses.push(steelo2Facet.address)
    let selectors = getSelectors(steelo2Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steelo2Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steelo2Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steelo2Facet Added To Diamond");
    return steelo2Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteelo2Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteelo2Facet = deploySteelo2Facet
