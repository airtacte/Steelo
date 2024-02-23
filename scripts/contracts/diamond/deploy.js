const { getSelectors, FacetCutAction } = require('../../libraries/diamond.js')

async function deployContract(name) {
  const ContractFactory = await ethers.getContractFactory(name)
  const contract = await ContractFactory.deploy()
  await contract.deployed()
  console.log(`${name} deployed:`, contract.address)
  return contract
}

async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]

  try {
    const diamondCutFacet = await deployContract('DiamondCutFacet')
    const diamond = await deployContract('Diamond')
    const diamondInit = await deployContract('DiamondInit')

    console.log('Deploying facets')
    const FacetNames = ['DiamondLoupeFacet', 'OwnershipFacet']
    const cut = []
    for (const FacetName of FacetNames) {
      const facet = await deployContract(FacetName)
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(facet)
      })
    }

    console.log('Diamond Cut:', cut)
    const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
    let functionCall = diamondInit.interface.encodeFunctionData('init')
    let tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
    console.log('Diamond cut tx: ', tx.hash)
    let receipt = await tx.wait()
    if (!receipt.status) {
      throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    console.log('Completed diamond cut')
    return diamond.address
  } catch (error) {
    console.error(`Error deploying diamond: ${error.message}`)
    process.exit(1)
  }
}

if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = deployDiamond