/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployDiamond } = require('../scripts/deploy.js')

const { assert, expect } = require('chai')




describe('DiamondTest', async function () {
  let diamondAddress
  let diamondCutFacet
  let diamondLoupeFacet
  let ownershipFacet
  let tx
  let receipt
  let result
  const addresses = []
  let owner, addr1, addr2, addr3, addr4, addr5, addr6;
  this.timeout(60000);

  before(async function () {
    [owner, addr1, addr2, addr3, addr4, addr5, addr6] = await ethers.getSigners();
    diamondAddress = await deployDiamond()
    diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)
    ownershipFacet = await ethers.getContractAt('OwnershipFacet', diamondAddress)
  })

  it('should have three facets', async () => {
    for (const address of await diamondLoupeFacet.facetAddresses()) {
      addresses.push(address)
    }

    assert.equal(addresses.length, 3)
  }).timeout(600000);
  it('add the Village Facet', async () => {

      const VillageFacet = await ethers.getContractFactory('VillageFacet')
      const villageFacet = await VillageFacet.deploy()
  
      let selectors = getSelectors(villageFacet);
      let addresses = [];
      addresses.push(villageFacet.address);
      
      await diamondCutFacet.diamondCut([[villageFacet.address, FacetCutAction.Add, selectors]], ethers.constants.AddressZero, '0x');
  
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0]);
      assert.sameMembers(result, selectors)
  
    }).timeout(600000)



   it('send arr1 from owner a message', async () => { 
  
	const Village = await ethers.getContractAt('VillageFacet', diamondAddress);
	let message = "Hi, bro how are you?";
  	await expect(Village.connect(owner).sendMessage(0, addr1.address, message)).to.not.be.reverted;

    })
    it('send owner from addr1 a message', async () => { 
  
	const Village = await ethers.getContractAt('VillageFacet', diamondAddress);
	let message = "I am good yo?";
  	await expect(Village.connect(addr1).sendMessage(0, owner.address, message)).to.not.be.reverted;

    })
    it('check if message is sent', async () => { 
  
      const Village = await ethers.getContractAt('VillageFacet', diamondAddress);
      let chat = await Village.connect(owner).getChat(0, addr1.address);
      console.log(chat);

    })
    it('check contacts of owner', async () => { 
  
      const Village = await ethers.getContractAt('VillageFacet', diamondAddress);
      let contacts = await Village.connect(owner).getContacts(0);
      console.log(contacts);

    })
    it('check contacts of addr1', async () => { 
  
      const Village = await ethers.getContractAt('VillageFacet', diamondAddress);
      let contacts = await Village.connect(addr1).getContacts(0);
      console.log(contacts);

    })

    
 
	
});
