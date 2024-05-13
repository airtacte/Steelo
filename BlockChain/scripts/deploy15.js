/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteez7Facet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x2Ef4b738e2119DDB78A95Bf075ECd879747660Ff";
    console.log("diamondAddress", diamondAddress);

    const STEEZ7Facet = await ethers.getContractFactory('STEEZ7Facet')
    const steez7Facet = await STEEZ7Facet.deploy()

    console.log('Deployed steez7Facet to ', steez7Facet.address)

    let addresses = [];
    addresses.push(steez7Facet.address)
    let selectors = getSelectors(steez7Facet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steez7Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steez7Facet.address)
    assert.sameMembers(result, selectors)
    console.log("steez7Facet Added To Diamond");
    return steez7Facet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteez7Facet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteez7Facet = deploySteez7Facet
