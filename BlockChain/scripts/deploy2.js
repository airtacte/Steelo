/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteeloFacet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x7d4bEd8E3AF826753701e088aD4D369e08137182";
    console.log("diamondAddress", diamondAddress);

    const STEELOFacet = await ethers.getContractFactory('STEELOFacet')
    const steeloFacet = await STEELOFacet.deploy()

    console.log('Deployed steeloFacet to ', steeloFacet.address)

    let addresses = [];
    addresses.push(steeloFacet.address)
    let selectors = getSelectors(steeloFacet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steeloFacet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steeloFacet.address)
    assert.sameMembers(result, selectors)
    console.log("steeloFacet Added To Diamond");
    return steeloFacet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteeloFacet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteeloFacet = deploySteeloFacet
