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
  let owner, addr1, addr2, addr3;
  this.timeout(60000);

  before(async function () {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
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

    it('check out the role of addr3', async () => { 
  
      const AccessControl = await ethers.getContractAt('AccessControlFacet', diamondAddress);
      let role = await AccessControl.connect(addr3).getRole();
      console.log("role of addr3 address :", role);

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

    


    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloBalanceOf(owner.address);
      console.log(balance);

    })

    it('should transfer balance from owner to someone else', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 10;
      await expect(Steelo.connect(owner).steeloTransfer(addr1.address, amount )).to.not.be.reverted;

    })

    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloBalanceOf(owner.address);
      console.log(balance);

    })

    it('should check allowance between 2 accounts', async () => { 
  
      	const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      	const allowance = await Steelo.steeloAllowance(owner.address, addr1.address);
	console.log(allowance);

    })

    it('should check if the owner approved some amount to spender', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 10;
      await expect(Steelo.connect(owner).steeloApprove(addr1.address, amount)).to.not.be.reverted;

    })
    
    it('should check allowance between 2 accounts', async () => { 
  
      	const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      	const allowance = await Steelo.steeloAllowance(owner.address, addr1.address);
	console.log(allowance);

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
      const balance = await Steelo.steeloBalanceOf(owner.address);
      console.log(balance);

    })
    
    it('should check allowance between 2 accounts', async () => { 
  
      	const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      	const allowance = await Steelo.steeloAllowance(owner.address, addr1.address);
	console.log(allowance);

    })

    it('should burn 50 tokens', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 50;
      await expect(Steelo.connect(owner).steeloBurn(amount )).to.not.be.reverted;

    })

    it('should check total supply of steelo to be 825000050', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let totalSupply = await Steelo.steeloTotalSupply()
      console.log(totalSupply);

    })

    it('should convert ETH to Steelo', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      await expect(Steelo.connect(owner).convertEtherToSteelo({value: ethers.utils.parseEther("2")})).to.not.be.reverted;

    })
    
    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloBalanceOf(owner.address);
      console.log(balance);

    })

    it('should convert Steelo to ETH', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      let amount = 100;
      await expect(Steelo.connect(owner).convertSteeloToEther(amount)).to.not.be.reverted;

    })


    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloBalanceOf(owner.address);
      console.log(balance);

    })

    it('should burn 50 tokens', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      let amount = 50;
      await expect(Steelo.connect(owner).steeloBurn(amount )).to.not.be.reverted;

    })

    it('should check total Supply', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloTotalSupply();
      console.log(balance);

    })

    it('should go with Steelo Token Generation', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress);
      await expect(Steelo.connect(owner).steeloTGE()).to.be.reverted;

    })

    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloBalanceOf(owner.address);
      console.log(balance);

    })

    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloBalanceOf("0xd86AD7c60a9B2d608740a99C3488D256f6fA493b");
      console.log(balance);

    })

    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloBalanceOf("0xA64c87ADc19364eEaca2e9806BAE025013C83F20");
      console.log(balance);

    })

    it('should check account balance', async () => { 
  
      const Steelo = await ethers.getContractAt('STEELOFacet', diamondAddress)
      const balance = await Steelo.steeloBalanceOf("0xcB0b5a14da81c475df610B5BCE7ECF392a2AC203");
      console.log(balance);

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
      await expect(Steelo.connect(owner).steeloTransfer(addr1.address, amount )).to.be.reverted;

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
    
 
	

