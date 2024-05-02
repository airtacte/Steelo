    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./LibAppStorage.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AppConstants} from "./LibAppStorage.sol";
import { Steez } from "./LibAppStorage.sol";



library LibSteelo {

	function initiate(address treasury) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(!s.steeloInitiated, "steelo already initiated");
		require( treasury != address(0), "treasurer can not be zeero address");
		require(s.executiveMembers[treasury], "only executive can initialize the steelo tokens");
		s.name = "Steelo";
		s.symbol = "STLO";
//		if (s.balances[treasury] == 0) {
//			mint(treasury, AppConstants.TGE_AMOUNT);
//			s.treasury = treasury;
//		}
		s.treasury = treasury;
//		s.lastMintEvent = block.timestamp;
		s.steeloCurrentPrice = 0.05 * (10 ** 6);
//		s.steeloCurrentPrice = 500 * (10 ** 6);
		s.steeloInitiated = true;
		
		
	}

	function TGE(address treasury) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require( treasury != address(0), "token can not be generated with zero address");
		require(s.executiveMembers[treasury], "only executive can initialize the steelo tokens");
		require(!s.tgeExecuted, "STEELOFacet: steeloTGE can only be executed once");
		require(s.totalTransactionCount == 0, "STEELOFacet: TransactionCount must be equal to 0");
		require(s.steeloCurrentPrice > 0, "STEELOFacet: steeloCurrentPrice must be greater than 0");
		require(s.totalSupply == 0, "STEELOFacet: steeloTGE can only be called for the Token Generation Event");


		uint256 communityAmount = (AppConstants.TGE_AMOUNT * AppConstants.communityTGE) / 100;
        	uint256 foundersAmount = (AppConstants.TGE_AMOUNT * AppConstants.foundersTGE) / 100;
        	uint256 earlyInvestorsAmount = (AppConstants.TGE_AMOUNT * AppConstants.earlyInvestorsTGE) / 100;
        	uint256 treasuryAmount = (AppConstants.TGE_AMOUNT * AppConstants.trasuryTGE) / 100;


		mint(AppConstants.communityAddress, communityAmount);
        	mint(AppConstants.foundersAddress, foundersAmount);
        	mint(AppConstants.earlyInvestorsAddress, earlyInvestorsAmount);
        	mint(s.treasury, treasuryAmount);

		s.mintTransactionLimit = 1000;
        	s.tgeExecuted = true;
		
	}

	function approve(address from, address to, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.stakerMembers[from], "you must stake in order to approve steelo transaction");
		require( from != address(0), "STEELOFacet: Cannot transfer from the zero address" );
		require( amount > 0, "you can not approve 0 amount");
		require(s.balances[from] >= amount, "you can not approve what you do not have");
	        s.allowance[from][to] = amount;
	}




	function transfer(address from, address to, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require( from != address(0), "STEELOFacet: Cannot transfer from the zero address" );
		require( to != address(0), "STEELOFacet: Cannot transfer to the zero address" );
		require(s.stakerMembers[from], "you must stake in order to transfer steelo transaction");
		require(s.balances[from] >= amount, "you have insufficient steelo tokens to transfer");
		require( amount > 0, "you can not transfer 0 amount");
		uint256 transferAmount = amount;
		beforeTokenTransfer(from, transferAmount);
//		if (!s.executiveMembers[from]) {
		require(s.stakers[from].amount >= (amount / 100), "you have insufficient staked ether");
		s.stakers[from].amount -= (amount / 100);
		s.stakers[to].amount += (amount / 100);
		if ( s.stakers[to].endTime < s.stakers[from].endTime) {
			s.stakers[to].endTime = s.stakers[from].endTime;
		}
		if (s.stakers[to].month < s.stakers[from].month) {
			s.stakers[to].month = s.stakers[from].month;
		}
//		}
//		if (uint256(s.totalTransactionCount) >= s.mintTransactionLimit) {
//			s.mintTransactionLimit += 1000;
//			steeloMint(s.treasury);
//
//		}
		s.balances[from] -= transferAmount;
		s.balances[to] += transferAmount;
		
		s.stakerMembers[to] = true;
		s.totalTransactionCount += 1;
	}

	function transferFrom(address from, address to, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require( from != address(0), "STEELOFacet: Cannot transfer from the zero address" );
		require( to != address(0), "STEELOFacet: Cannot transfer to the zero address" );
		require(s.stakerMembers[from], "the sender must stake in order to transfer steelo transaction");
		require(s.balances[from] >= amount, "you have insufficient steelo tokens to transfer");
		require(s.allowance[from][to] >= amount, "did not allow this much allowance");
		require( amount > 0, "you can not transfer 0 amount");
		beforeTokenTransfer(from, amount);
		require(s.stakers[from].amount >= (amount / 100), "you have insufficient staked ether");
		s.stakers[from].amount -= (amount / 100);
		s.stakers[to].amount += (amount / 100);
		s.stakers[to].endTime = s.stakers[from].endTime;
//		if (uint256(s.totalTransactionCount) >= s.mintTransactionLimit) {
//			s.mintTransactionLimit += 1000;
//			steeloMint(s.treasury);
//
//		}
		s.balances[from] -= amount;
		s.balances[to] += amount;
		s.allowance[from][to] -= amount;
		s.stakerMembers[to] = true;
		s.totalTransactionCount += 1;
		
	}

	function burn(address from, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.adminMembers[from], "only admin can burn steelo tokens");
//		require(amount > 0, "can not burn 0 amount");
		require(amount < 825000000 * 10 ** 18, "can not burn 825 million tokens");
		require(s.balances[from] > amount, "you should have enough amount to burn some tokens");
	        s.balances[from] -= amount;
		s.totalSupply -= amount;
		s.totalTransactionCount += 1;
		s.totalBurned += amount;
	}

	function mint(address from, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
//		require(s.adminMembers[from], "only admins can mint steelo tokens");
//		require(amount > 0, "can not mint 0 amount");
//		require(amount <= 825000000 * 10 ** 18, "can not mint more than 825 million tokens");
	        s.balances[from] += amount;
		s.totalSupply += amount;
		s.totalTransactionCount += 1;
		s.totalMinted += amount;
	}


	function stake(address from, uint256 amount, uint256 month) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require(amount > 0, "you have no ether");
		require(month >= 1 && month <= 6, "duration of staking is between 1 and 6 months");
		require(s.balances[s.treasury] > (amount * 100), "treasury have insufficient steelo tokens");
		s.balances[from] += (amount * 100);
		s.balances[s.treasury] -= (amount * 100);
		s.stakers[from].amount += amount;
		s.stakers[from].endTime = block.timestamp + (month * 30 days);
		s.stakers[from].month = month;
		s.stakerMembers[from] = true;
		s.totalTransactionCount += 1;
	}

	function donateEther(address from, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require(amount > 0, "you have no ether");
		s.balances[s.treasury] += (amount * 100);
		s.totalTransactionCount += 1;
	}

	function stakePeriodEnder(address from, uint256 month) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		s.stakers[from].endTime -= (30 days * month);
	}

	function unstake(address from, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		
		
		s.balances[from] -= (amount * 100);
		s.balances[s.treasury] += (amount * 100);
		s.stakers[from].amount -= amount;
		s.totalTransactionCount += 1;
	}

	function getTotalTransactionAmount() internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		
		uint256 length = s.allCreatorIds.length;

//		for (uint256 i = 0; i < length; i++) {
//            		uint256 creatorId = s.allCreatorIds[i];
//            		s.totalTransactionCount += int256(s.steez[creatorId].transactionCount);
//        	}

	}

	function createRandomTransaction() internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.steez["XT67OYGFDSA"].transactionCount = 7;
		s.allCreatorIds = ["XT67OYGFDSA"];
	}

	function beforeTokenTransfer(address from, uint256 amount ) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();

        	s.burnAmount = calculateBurnAmount(amount);
        	if (s.burnAmount > 0 && from != address(0)) {
			require(s.balances[s.treasury] >= s.burnAmount, "treasury has insufficient steelo tokens to burn");
			s.balances[s.treasury] -= s.burnAmount;		
            		s.totalSupply -= s.burnAmount;
			s.totalBurned += s.burnAmount;
        	}
		s.mintAmount = calculateMintAmount(amount);
		if (s.mintAmount > 0 && from != address(0)) {
            		mintAdvanced(s.mintAmount);	
        	}
    }

    function mintAdvanced(uint256 amount) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.totalTransactionCount > 0, "STEELOFacet: TransactionCount must be equal to 0");
		require(s.steeloCurrentPrice > 0, "STEELOFacet: steeloCurrentPrice must be greater than 0");
		require(s.totalSupply > 0, "STEELOFacet: steeloTGE can only be called for the Token Generation Event");


//		uint256 communityAmount = (amount * AppConstants.communityTGE) / 100;
//        	uint256 foundersAmount = (amount * AppConstants.foundersTGE) / 100;
//        	uint256 earlyInvestorsAmount = (amount * AppConstants.earlyInvestorsTGE) / 100;
//        	uint256 treasuryAmount = (amount * AppConstants.trasuryTGE) / 100;


//		mint(AppConstants.communityAddress, communityAmount);
//        	mint(AppConstants.foundersAddress, foundersAmount);
//        	mint(AppConstants.earlyInvestorsAddress, earlyInvestorsAmount);
//        	mint(s.treasury, treasuryAmount);

		uint256 treasuryAmount = (amount * AppConstants.treasuryMint) / 100;
        	uint256 liquidityProvidersAmount = (amount * AppConstants.liquidityProvidersMint) / 100;
        	uint256 ecosystemProvidersAmount = (amount * AppConstants.ecosystemProvidersMint) / 100;
 

        	mint(s.treasury, treasuryAmount);
        	mint(AppConstants.liquidityProviders, liquidityProvidersAmount);
        	mint(AppConstants.ecosystemProviders, ecosystemProvidersAmount);

		s.totalMinted += s.mintAmount;
        	s.lastMintEvent = block.timestamp;
		
	}

    function calculateBurnAmount( uint256 transactionValue ) private returns (uint256) {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.burnRate = 0;
		if (s.steeloCurrentPrice <= AppConstants.pMin) {
			s.burnRate = 1;
		}
		if (s.steeloCurrentPrice <= AppConstants.pMin * 10) {
			s.burnRate = 5;
		}
		if (s.steeloCurrentPrice <= AppConstants.pMin * 100) {
			s.burnRate = 10;
		}
		

        	if (s.totalTransactionCount > 0) {
            		s.burnAmount = ((transactionValue * s.burnRate) / 1000);
			require( s.burnRate >= AppConstants.MIN_BURN_RATE && s.burnRate <= AppConstants.MAX_BURN_RATE, "STEELOFacet: Suggested Burn Rate not within permitted range");
            		return s.burnAmount;
        	} else {
            		return 0;
        	}

        	
    	}

	function calculateMintAmount( uint256 transactionValue ) private returns (uint256) {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.mintRate = 0;
		if (s.steeloCurrentPrice >= AppConstants.pMin) {
			s.mintRate = 1;
		}
		if (s.steeloCurrentPrice >= AppConstants.pMin * 10) {
			s.mintRate = 5;
		}
		if (s.steeloCurrentPrice >= AppConstants.pMin * 100) {
			s.mintRate = 10;
		}
		

        	if (s.totalTransactionCount > 0) {
            		s.mintAmount = ((transactionValue * s.mintRate) / 1000);
			require( s.mintRate >= AppConstants.MIN_MINT_RATE && s.burnRate <= AppConstants.MAX_MINT_RATE, "STEELOFacet: Suggested Mint Rate not within permitted range");
            		return s.mintAmount;
        	} else {
            		return 0;
        	}

        	
    	}

     function steeloMint(address from) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.mintAmount = calculateGenerationMintAmount();
		require( s.totalTransactionCount > 0,"STEELOFacet: s.totalTransactionCount must be greater than 0");
        	require(s.steeloCurrentPrice > 0,"STEELOFacet: steeloCurrentPrice must be greater than 0");

		uint256 treasuryAmount = (s.mintAmount * AppConstants.treasuryMint) / 100;
        	uint256 liquidityProvidersAmount = (s.mintAmount * AppConstants.liquidityProvidersMint) / 100;
        	uint256 ecosystemProvidersAmount = (s.mintAmount * AppConstants.ecosystemProvidersMint) / 100;


	       	s.totalMinted += s.mintAmount;
	       	s.lastMintEvent = block.timestamp;

        	mint(from, treasuryAmount);
        	mint(AppConstants.liquidityProviders, liquidityProvidersAmount);
        	mint(AppConstants.ecosystemProviders, ecosystemProvidersAmount);

        	
		
     }

     function calculateGenerationMintAmount() public returns (uint256) {
		AppStorage storage s = LibAppStorage.diamondStorage();
		uint256 adjustmentFactor = 1 * (10 ** 6);
        	if (s.steeloCurrentPrice >= AppConstants.pMax) {
            		adjustmentFactor += (((s.steeloCurrentPrice - AppConstants.pMax) * AppConstants.alpha) / 100);
        	} else if (s.steeloCurrentPrice <= AppConstants.pMin) {
            		adjustmentFactor -= (((AppConstants.pMin - s.steeloCurrentPrice) * AppConstants.beta) / 100);
        	} else {
            		adjustmentFactor += adjustmentFactor / 100;
        	}
        	s.mintAmount = (AppConstants.rho * uint256(s.totalTransactionCount) * adjustmentFactor) / 10 ** 15;
		s.mintAmount *= 10 ** 18;

        	return s.mintAmount;
    }

    function calculateSupplyCap () internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		uint256 currentSupply = s.totalSupply;
	        
	        if (s.steeloCurrentPrice < AppConstants.pMin) {
	        	s.supplyCap = (currentSupply - (AppConstants.delta * (AppConstants.pMin - s.steeloCurrentPrice) * currentSupply) / (10 ** 27));
        	} else {
            		s.supplyCap = currentSupply;
        	}
    	}

	function adjustMintRate(uint256 amount) internal {
		amount = amount * 10 ** 18;
		AppStorage storage s = LibAppStorage.diamondStorage();
//		require( s.mintRate >= AppConstants.MIN_MINT_RATE && amount <= AppConstants.MAX_MINT_RATE, "STEELOFacet: Invalid burn rate");
        	s.mintRate = amount;	
	}	

	function adjustBurnRate(uint256 amount) internal {
		amount = amount * 10 ** 18;
		AppStorage storage s = LibAppStorage.diamondStorage();
//		require( amount >= AppConstants.MIN_BURN_RATE && amount <= AppConstants.MAX_BURN_RATE, "STEELOFacet: Invalid burn rate");
        	s.burnRate = amount / 10 ** 18;	
	}

	function burnTokens(address from) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.burnAmount = 	(((s.steeloCurrentPrice * AppConstants.FEE_RATE) / 1000) * s.burnRate) / 100;
		burn(from, s.burnAmount);
		s.totalBurned += s.burnAmount;
        	s.lastBurnEvent = block.timestamp;
	}

	function verifyTransaction(uint256 sipId) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
//        	require(sipId < s.lastSipId, "SIP does not exist");
		s.sips[sipId].voteCountForCreator = 2;
		s.sips[sipId].voteCountForCommunity = 4;
		s.sips[sipId].voteCountForSteelo = 6;
	}
}
