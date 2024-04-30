/* global ethers */
/* eslint prefer-const: "off" */
const { assert, expect } = require('chai')

// const { deployDiamond } = require('./deploy2.js')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deploySteezFacet () {
    // diamondAddress = await deployDiamond()
    
    diamondAddress = "0x6b3e010c4EcCaB1519C32684CfE0B93B2347b53C";
    console.log("diamondAddress", diamondAddress);

    const STEEZFacet = await ethers.getContractFactory('STEEZFacet')
    const steezFacet = await STEEZFacet.deploy()

    console.log('Deployed steezFacet to ', steezFacet.address)

    let addresses = [];
    addresses.push(steezFacet.address)
    let selectors = getSelectors(steezFacet)

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    tx = await diamondCutFacet.diamondCut(
    [{
        facetAddress: steezFacet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
    receipt = await tx.wait()
    if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(steezFacet.address)
    assert.sameMembers(result, selectors)
    console.log("steezFacet Added To Diamond");
    return steezFacet.address;

}

// We recommend this pattern to be able to use async/await every where
// and properly handle errors.
if (require.main === module) {
    deploySteezFacet()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deploySteezFacet = deploySteezFacet
