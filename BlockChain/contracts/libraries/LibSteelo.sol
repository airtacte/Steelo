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
		if (s.balances[treasury] == 0) {
			mint(treasury, AppConstants.TGE_AMOUNT);
			s.treasury = treasury;
		}
		s.lastMintEvent = block.timestamp;
		s.steeloInitiated = true;
		
		
	}

	function TGE(address treasury) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require( treasury != address(0), "token can not be generated with zero address");
		require(s.executiveMembers[treasury], "only executive can initialize the steelo tokens");
		require(!s.tgeExecuted, "STEELOFacet: steeloTGE can only be executed once");
		require(s.totalTransactionCount == 0, "STEELOFacet: TransactionCount must be equal to 0");
		require(s.steeloCurrentPrice >= 0, "STEELOFacet: steeloCurrentPrice must be greater than 0");
		require(s.totalSupply == AppConstants.TGE_AMOUNT, "STEELOFacet: steeloTGE can only be called for the Token Generation Event");


		uint256 communityAmount = (AppConstants.TGE_AMOUNT * AppConstants.communityTGE) / 100;
        	uint256 foundersAmount = (AppConstants.TGE_AMOUNT * AppConstants.foundersTGE) / 100;
        	uint256 earlyInvestorsAmount = (AppConstants.TGE_AMOUNT * AppConstants.earlyInvestorsTGE) / 100;
        	uint256 treasuryAmount = (AppConstants.TGE_AMOUNT * AppConstants.trasuryTGE) / 100;


		mint(AppConstants.communityAddress, communityAmount);
        	mint(AppConstants.foundersAddress, foundersAmount);
        	mint(AppConstants.earlyInvestorsAddress, earlyInvestorsAmount);
        	mint(msg.sender, treasuryAmount);

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
		uint256 feeAmount = (amount * AppConstants.FEE_RATE) / 10000;
		uint256 transferAmount = amount - feeAmount;
		beforeTokenTransfer(from, transferAmount);
        	beforeTokenTransfer(from, feeAmount);
		s.balances[from] -= transferAmount;
		s.balances[to] += transferAmount;
		s.stakerMembers[to] = true;
	}

	function transferFrom(address from, address to, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require( from != address(0), "STEELOFacet: Cannot transfer from the zero address" );
		require( to != address(0), "STEELOFacet: Cannot transfer to the zero address" );
		require(s.stakerMembers[from], "the sender must stake in order to transfer steelo transaction");
		require(s.balances[from] >= amount, "you have insufficient steelo tokens to transfer");
		require(s.allowance[from][to] >= amount, "did not allow this much allowance");
		require( amount > 0, "you can not transfer 0 amount");
		s.balances[from] -= amount;
		s.balances[to] += amount;
		s.allowance[from][to] -= amount;
		s.stakerMembers[to] = true;
		
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
	}

	function mint(address from, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.adminMembers[from], "only admins can mint steelo tokens");
		require(amount > 0, "can not mint 0 amount");
		require(amount <= 825000000 * 10 ** 18, "can not mint more than 825 million tokens");
	        s.balances[from] += amount;
		s.totalSupply += amount;
		s.totalTransactionCount += 1;
	}


	function donate(address from, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require(amount > 0, "you have no ether");
		require(s.balances[s.treasury] > (amount * 100), "treasury have insufficient steelo tokens");
		s.balances[from] += (amount * 100);
		s.balances[s.treasury] -= (amount * 100);
		s.totalTransactionCount += 1;
	}

	function withdraw(address from, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require(address(this).balance >= (amount * (10 ** 18)), "no ether is available in the treasury of contract balance");
		require(s.balances[from] >= amount, "not sufficient steelo tokens to sell");
		s.balances[from] -= (amount * 100 * (10 ** 18));
		s.balances[s.treasury] += (amount * 100 * (10 ** 18));
		s.totalTransactionCount += 1;
	}

	function getTotalTransactionAmount() internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		
		uint256 length = s.allCreatorIds.length;

		for (uint256 i = 0; i < length; i++) {
            		uint256 creatorId = s.allCreatorIds[i];
            		s.totalTransactionCount += int256(s.steez[creatorId].transactionCount);
        	}

	}

	function createRandomTransaction() internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.steez[1].transactionCount = 7;
		s.allCreatorIds = [1];
	}

	function beforeTokenTransfer(address from, uint256 amount ) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();

        	s.burnAmount = calculateBurnAmount(amount);
        	if (s.burnAmount > 0 && from != address(0)) {
            		burn(from, s.burnAmount);
            		amount -= s.burnAmount;
        }
    }

    function calculateBurnAmount( uint256 transactionValue ) private returns (uint256) {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.burnRate = 1;
		

        	if (s.totalTransactionCount > 0) {
            		s.burnAmount = ((transactionValue * AppConstants.FEE_RATE * s.burnRate) / 1000);
			require( s.burnAmount >= AppConstants.MIN_BURN_RATE && s.burnAmount <= AppConstants.MAX_BURN_RATE, "STEELOFacet: Suggested Burn Rate not within permitted range");
            		return s.burnAmount;
        	} else {
            		return 0;
        	}

        	
    	}

     function steeloMint(address from) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.mintAmount = calculateMintAmount( s.totalTransactionCount, s.steeloCurrentPrice);
		require( s.totalTransactionCount > 0,"STEELOFacet: s.totalTransactionCount must be greater than 0");
        	require(s.steeloCurrentPrice >= 0,"STEELOFacet: steeloCurrentPrice must be greater than 0");

		uint256 treasuryAmount = (s.mintAmount * AppConstants.treasuryMint) / 100;
        	uint256 liquidityProvidersAmount = (s.mintAmount * AppConstants.liquidityProvidersMint) / 100;
        	uint256 ecosystemProvidersAmount = (s.mintAmount * AppConstants.ecosystemProvidersMint) / 100;


        	s.totalMinted += s.mintAmount;
        	s.lastMintEvent = block.timestamp;

        	mint(from, treasuryAmount);
        	mint(AppConstants.liquidityProviders, liquidityProvidersAmount);
        	mint(AppConstants.ecosystemProviders, ecosystemProvidersAmount);

        	
		
     }

     function calculateMintAmount( int256 totalTransactionCount, uint256 steeloCurrentPrice ) public returns (uint256) {
		AppStorage storage s = LibAppStorage.diamondStorage();
		uint256 adjustmentFactor = 100 * 10 ** 18;
        	if (s.steeloCurrentPrice >= AppConstants.pMax) {
            		adjustmentFactor += ((s.steeloCurrentPrice - AppConstants.pMax) * AppConstants.alpha) / 100;
        	} else if (s.steeloCurrentPrice <= AppConstants.pMin) {
            		adjustmentFactor -= ((AppConstants.pMin - s.steeloCurrentPrice) * AppConstants.beta) / 100;
        	} else {
            		adjustmentFactor += adjustmentFactor / 100;
        	}
        	s.mintAmount = (AppConstants.rho * uint256(s.totalTransactionCount) * adjustmentFactor) / 10 ** 18;
		s.mintAmount = s.mintAmount / 100;
		require( s.mintAmount >= AppConstants.MIN_MINT_RATE && s.mintAmount <= AppConstants.MAX_MINT_RATE, "STEELOFacet: Suggested Mint Rate not within permitted range");


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
		require( amount >= AppConstants.MIN_MINT_RATE && amount <= AppConstants.MAX_MINT_RATE, "STEELOFacet: Invalid burn rate");
        	s.mintRate = amount;	
	}	

	function adjustBurnRate(uint256 amount) internal {
		amount = amount * 10 ** 18;
		AppStorage storage s = LibAppStorage.diamondStorage();
		require( amount >= AppConstants.MIN_BURN_RATE && amount <= AppConstants.MAX_BURN_RATE, "STEELOFacet: Invalid burn rate");
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
