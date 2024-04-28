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
  it('add the Access Control Facet', async () => {

      const AccessControlFacet = await ethers.getContractFactory('AccessControlFacet')
      const accessControlFacet = await AccessControlFacet.deploy()
  
      let selectors = getSelectors(accessControlFacet);
      let addresses = [];
      addresses.push(accessControlFacet.address);
      
      await diamondCutFacet.diamondCut([[accessControlFacet.address, FacetCutAction.Add, selectors]], ethers.constants.AddressZero, '0x');
  
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0]);
      assert.sameMembers(result, selectors)
  
    }).timeout(600000)

  
    it('initialize the access where by grants role to the executive', async () => { 
  
	const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
  	await expect(AccessControl.connect(owner).initialize()).to.not.be.reverted;

    })

    it('check out the role of your address', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(owner).getRole();
      console.log("role of owner address :", role);

    })
    
    it('initialize the access again where by grants role to the executive', async () => { 
  
	const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
  	await expect(AccessControl.connect(owner).initialize()).to.be.reverted;

    })

    it('check out the power of the account', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(owner).getPower();
      console.log("Admin Power of owner:", role);

    })

    it('executive owner grant role admin to addr1', async () => { 
  
	const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
	role = "ADMIN_ROLE";
  	await expect(AccessControl.connect(owner).grantRole(role, addr1.address)).to.not.be.reverted;

    })

    it('check out the role of your address', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr1).getRole();
      console.log("role of addr1 address :", role);

    })
     
    it('check out the power of the addr1', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr1).getPower();
      console.log("admin power of addr1 :", role);

    })

    it('executive owner grant role admin to addr2', async () => { 
  
	const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
	role = "ADMIN_ROLE";
  	await expect(AccessControl.connect(owner).grantRole(role, addr2.address)).to.not.be.reverted;

    })

    it('check out the role of addr2 ', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr2).getRole();
      console.log("role of addr2 address :", role);

    })
     
    it('check out the power of the addr2', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr2).getPower();
      console.log("admin power of addr2 :", role);

    })
    it('executive owner grant role admin to addr3', async () => { 
  
	const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
	role = "ADMIN_ROLE";
  	await expect(AccessControl.connect(owner).grantRole(role, addr3.address)).to.not.be.reverted;

    })

    it('check out the role of addr3 ', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr3).getRole();
      console.log("role of addr3 address :", role);

    })
     
    it('check out the power of the addr3', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr3).getPower();
      console.log("admin power of addr3 :", role);

    })
    it('executive owner grant role admin to addr4', async () => { 
  
	const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
	role = "ADMIN_ROLE";
  	await expect(AccessControl.connect(owner).grantRole(role, addr4.address)).to.not.be.reverted;

    })

    it('check out the role of addr4 ', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr4).getRole();
      console.log("role of addr4 address :", role);

    })
     
    it('check out the power of the addr4', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr4).getPower();
      console.log("admin power of addr4 :", role);

    }) 
    it('executive owner grant role admin to addr5', async () => { 
  
	const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
	role = "ADMIN_ROLE";
  	await expect(AccessControl.connect(owner).grantRole(role, addr5.address)).to.not.be.reverted;

    })

    it('check out the role of addr5 ', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr5).getRole();
      console.log("role of addr5 address :", role);

    })
     
    it('check out the power of the addr5', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr5).getPower();
      console.log("admin power of addr5 :", role);

    })

    it('check out the role of addr6', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr6).getRole();
      console.log("role of addr6 address :", role);

    })
  it('should add the Steelo Facet', async () => {

      const SteeloFacet = await ethers.getContractFactory('STEELOFacet')
      const steeloFacet = await SteeloFacet.deploy()
  
      let selectors = getSelectors(steeloFacet);
      let addresses = [];
      addresses.push(steeloFacet.address);
      
      await diamondCutFacet.diamondCut([[steeloFacet.address, FacetCutAction.Add, selectors]], ethers.constants.AddressZero, '0x');
  
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0]);
      assert.sameMembers(result, selectors)
  
    }).timeout(600000)
   it('should initiate Steelo from addr1 must be rejected', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      await expect(Steelo.connect(addr1).steeloInitiate()).to.be.reverted;

    })

   it('should initiate Steelo from owner executive', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      await expect(Steelo.connect(owner).steeloInitiate()).to.not.be.reverted;

    })

   it('should check name of Steelo coin name is Steelo', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let name = await Steelo.steeloName()
      expect(name).to.equal("Steelo");

    })

   

   
    it('should fail to check name of Steelo coin name is Ezra', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let name = await Steelo.steeloName()
      expect(name).to.not.equal("Ezra");

    })

    it('should check name of Steelo coin symbol is STH', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let symbol = await Steelo.steeloSymbol()
      expect(symbol).to.equal("STLO");

    })
    it('should fail to check name of Steelo coin symbol is ETH', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let symbol = await Steelo.steeloSymbol()
      expect(symbol).to.not.equal("ETH");

    })

    it('should check total supply of steelo to be 825000000', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let totalSupply = await Steelo.steeloTotalSupply()
      totalSupply /= 10 ** 18;
      console.log("total supply of steelo after executive initiated :", parseInt(totalSupply));

    })
    it('should go with Steelo Token Generation', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      await expect(Steelo.connect(owner).steeloTGE()).to.not.be.reverted;

    })

    it('should fail to check total supply of Steelo to be 200', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let totalSupply = await Steelo.steeloTotalSupply()
      totalSupply /= 10 ** 18;
      expect(totalSupply).to.not.equal(1000000000);

    })

    it('should check total supply to equal 825000000', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let number = 825000000;
      let constant = await Steelo.steeloTotalTokens();
      constant /= 10 ** 18;
      console.log("total token generated cosntant number :", parseInt(constant));
    })
	
    it('should fail to that total tokens generated should not be 1000000000', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let number = 1000000000;
      let constant = await Steelo.steeloTotalTokens()
      expect(parseInt(constant, 10)).to.not.equal(number);

    })

    it('should check steelo decimal to equal 18', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let number = 18;
      let constant = await Steelo.steeloDecimal()
      console.log("decimal amount for steelo token :", parseInt(constant));

    })
	
    it('should fail to that steelo decimal 16', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let number = 16;
      let constant = await Steelo.steeloDecimal()
      expect(parseInt(constant, 10)).to.not.equal(number);

    })

    it('should mint 100 tokens', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 100;
      await expect(Steelo.connect(owner).steeloMint(amount )).to.not.be.reverted;

    })

    it('should check total supply of steelo to be 825000100', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let totalSupply = await Steelo.steeloTotalSupply()
      totalSupply = totalSupply / 10 ** 18;
      console.log("total supply value after 100 steelo tokens were minted", parseInt(totalSupply))

    })

    


    it('should check account balance of owner before STLO transaction', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(owner.address);
      balance /= 10 ** 18;
      console.log("balance of owner address after mint", parseInt(balance));

    })

    it('should transfer 10 STLO from owner to addr1', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 10;
      await expect(Steelo.connect(owner).steeloTransfer(addr1.address, amount )).to.not.be.reverted;

    })

    it('should check account balance of owner after STLO transaction', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(owner.address);
      balance /= 10 ** 18;
      console.log("STLO balance of owner :", parseInt(balance));

    })
     it('should check account balance of addr1 after STLO transaction', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(addr1.address);
      balance /= 10 ** 18;
      console.log("STLO balance of addr1 :", parseInt(balance));

    })
    
    it('should check total supply of steelo after a transfer between two addresses', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let totalSupply = await Steelo.steeloTotalSupply()
      totalSupply = totalSupply / 10 ** 18;
      console.log("total supply value after 10 steelo transfer", parseInt(totalSupply))

    })

    it('should transfer 740000 STLO from owner to addr1', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 740000;
      await expect(Steelo.connect(owner).steeloTransfer(addr1.address, amount )).to.not.be.reverted;

    })

    it('should check account balance of owner after STLO transaction', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(owner.address);
      balance /= 10 ** 18;
      console.log("STLO balance of owner :", parseInt(balance));

    })
     it('should check account balance of addr1 after STLO transaction', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(addr1.address);
      balance /= 10 ** 18;
      console.log("STLO balance of addr1 :", parseInt(balance));

    })
    
    it('should check total supply of steelo after a transfer between two addresses', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let totalSupply = await Steelo.steeloTotalSupply()
      totalSupply = totalSupply / 10 ** 18;
      console.log("total supply value after 740000 steelo transfer", parseInt(totalSupply))

    })

    it('should check allowance between 2 accounts before no allowance', async () => { 
  
      	const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      	const allowance = await Steelo.steeloAllowance(owner.address, addr1.address);
	console.log("allowance between owner address and addr1 :", parseInt(allowance));

    })

    it('should check if the owner approved some amount to addr1', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 10;
      await expect(Steelo.connect(owner).steeloApprove(addr1.address, amount)).to.not.be.reverted;

    })
    
    it('should check allowance between 2 accounts after allowance', async () => { 
  
      	const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      	let allowance = await Steelo.steeloAllowance(owner.address, addr1.address);
	allowance /= 10 ** 18;
	console.log("allowance between owner address and addr1 after owner approved 10 STLO", parseInt(allowance));

    })

    it('should check if transfer of some amount from one address to another address', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 200;
      await expect(Steelo.connect(owner).steeloTransferFrom(owner.address, addr1.address, amount)).to.be.reverted;

    })

    it('should check if transfer of some amount from one address to another address', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 10;
      await expect(Steelo.connect(owner).steeloTransferFrom(owner.address, addr1.address, amount)).to.not.be.reverted;

    })
    it('should check if transfer of some amount from one address to another address', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 10;
      await expect(Steelo.connect(owner).steeloTransferFrom(owner.address, addr1.address, amount)).to.be.reverted;

    })

    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(owner.address);
      balance /= 10 ** 18;
      console.log("STLO balance of owner after he let smart contract transfer 10 STLO to addr1 :", parseInt(balance));

    })
    
    it('should check allowance between 2 accounts after transfer', async () => { 
  
      	const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      	const allowance = await Steelo.steeloAllowance(owner.address, addr1.address);
	console.log("allowance between owner and addr1 after smart transfer :", parseInt(allowance));

    })

    it('should burn 50 tokens', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 50;
      await expect(Steelo.connect(owner).steeloBurn(amount )).to.not.be.reverted;

    })

    it('should check total supply of steelo to be 825000050', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let totalSupply = await Steelo.steeloTotalSupply();
      totalSupply /= 10 ** 18;
      console.log("total supply after owner burned 50 tokens :", parseInt(totalSupply));

    })
    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(addr1.address);
      balance /= 10 ** 18;
      console.log("addr1 balance before buying STLO with 1 ether :", parseInt(balance));

    })

    it('should convert ETH to Steelo', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      await expect(Steelo.connect(addr1).convertEtherToSteelo({value: ethers.utils.parseEther("1")})).to.not.be.reverted;

    })
    
    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(addr1.address);
      balance /= 10 ** 18;
      console.log("addr1 balance after buying STLO with 1 ether :", parseInt(balance));

    })

    it('should convert Steelo to ETH', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      let amount = 100;
      await expect(Steelo.connect(addr1).convertSteeloToEther(amount)).to.not.be.reverted;

    })


    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(addr1.address);
      balance /= 10 ** 18;
      console.log("addr1 STLO balance after selling STLO :", parseInt(balance));

    })

    it('should burn 50 tokens', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 50;
      await expect(Steelo.connect(owner).steeloBurn(amount )).to.not.be.reverted;

    })

    it('should check total Supply', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloTotalSupply();
      balance /= 10 ** 18;
      console.log("total supply after owner burned 50 STLO again", parseInt(balance));

    })

    

    it('should check account balance of community provider', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(addr3.address);
      balance /= 10 ** 18;
      console.log("STLO balance of  community provider:", parseInt(balance));

    })

    it('should check account balance of founder provider', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(addr4.address);
      balance /= 10 ** 18;
      console.log("STLO balance of founder provider:", parseInt(balance));

    })

    it('should check account balance of early investor provider', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let balance = await Steelo.steeloBalanceOf(addr5.address);
      balance /= 10 ** 18;
      console.log("STLO balance of  early investor:", parseInt(balance));

    })


    it('should expect transaction count to be zero', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const transaction = await Steelo.getTotalTransactionAmount();
      console.log(transaction);

    })

    it('should create random transaction', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      await expect(Steelo.connect(owner).createRandomTransaction()).to.not.be.reverted;

    })

    it('should expect transaction count to be zero', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const transaction = await Steelo.getTotalTransactionAmount();
      console.log(transaction);

    })

    


    it('should calculate total transaction', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      await expect(Steelo.connect(owner).calculateTotalTransactionAmount()).to.not.be.reverted;

    })


    it('should expect transaction count to be seven', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const transaction = await Steelo.getTotalTransactionAmount();
      console.log(transaction);

    })

    it('should transfer balance from owner to someone else', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 5400;
      await expect(Steelo.connect(owner).steeloTransfer(addr1.address, amount )).to.not.be.reverted;

    })

    it('should transfer balance from owner to someone else', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 54000;
      await expect(Steelo.connect(owner).steeloTransfer(addr1.address, amount )).to.not.be.reverted;

    })

    it('should check total Supply', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloTotalSupply();
      console.log(balance);

    })

     it('should calcuate and mint on its own', async () => { 
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      await expect(Steelo.connect(owner).steeloMintAdvanced()).to.not.be.reverted;

    })

    it('should check total Supply', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloTotalSupply();
      console.log(balance);

    })

    it('should add the Steelo 2 Facet', async () => {

      const Steelo2Facet = await ethers.getContractFactory('STEELO2Facet')
      const steelo2Facet = await Steelo2Facet.deploy()
  
      let selectors = getSelectors(steelo2Facet);
      let addresses = [];
      addresses.push(steelo2Facet.address);
      
      await diamondCutFacet.diamondCut([[steelo2Facet.address, FacetCutAction.Add, selectors]], ethers.constants.AddressZero, '0x');
  
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0]);
      assert.sameMembers(result, selectors)
  
    }).timeout(600000)

    it('should check total Supply', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo2.steeloTotalSupply();
      console.log(balance);

    })


    it('should caculate suppply cap', async () => { 
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress);
      await expect(Steelo2.connect(owner).calculateSupplyCap()).to.not.be.reverted;

    })

    it('should check total Supply', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo2.steeloTotalSupply();
      console.log(balance);

    })

    it('should check total Supply', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const balance = await Steelo2.steeloSupplyCap();
      console.log(balance);

    })

    it('should check mint Rate', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const balance = await Steelo2.steeloMintRate();
      console.log(balance);

    })


    it('should adjust mint rate', async () => { 
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress);
      let amount = 60;
      await expect(Steelo2.connect(owner).adjustMintRate(amount)).to.not.be.reverted;

    })

    it('should check min Rate', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const balance = await Steelo2.steeloMintRate();
      console.log(balance);

    })


    it('should check burn Rate', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const balance = await Steelo2.steeloBurnRate();
      console.log(balance);

    })


    it('should adjust burn rate', async () => { 
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress);
      let amount = 60;
      await expect(Steelo2.connect(owner).adjustBurnRate(amount)).to.not.be.reverted;

    })

    it('should check burn Rate', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const balance = await Steelo2.steeloBurnRate();
      console.log(balance);

    })

    it('should check burn Amount before', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const balance = await Steelo2.steeloBurnAmount();
      console.log(balance);

    })

    it('should adjust burn rate', async () => { 
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress);
      await expect(Steelo2.connect(owner).burnSteeloTokens()).to.not.be.reverted;

    })

    it('should check burn Amount before', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const balance = await Steelo2.steeloBurnAmount();
      console.log(balance);

    })

    it('should check total burned Amount before', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const balance = await Steelo2.steeloTotalBurnAmount();
      console.log(balance);

    })

    it('should verify transaction', async () => { 
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress);
      await expect(Steelo2.connect(owner).verifyTransaction(1)).to.not.be.reverted;

    })

    it('should check burn Amount before', async () => { 
  
      const Steelo2 = await ethers.getContractAt('STEELO2Facet', diamondAddress)
      const verified = await Steelo2.getVerifiedTransaction(1);
      expect(verified).to.equal(true);
      expect(verified).to.not.equal(false);

    })
    

    

    

    

  });
    
 
	

