// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibSteez} from "../libraries/LibSteez.sol";
import {AppConstants, Seller, Steez, Creator, CreatorSteez} from "../libraries/LibAppStorage.sol";


contract STEEZ2Facet {
   
	AppStorage internal s;


	function launchStarter(string memory creatorId) public {
		LibSteez.launchStarter(creatorId);
	}
    	
	function bidLaunch(string memory creatorId, uint256 amount) public payable {		
		LibSteez.bidLaunch(msg.sender, creatorId, amount);
	}
	function initiateP2PSell(string memory creatorId, uint256 sellingAmount, uint256 steezAmount) public {
		LibSteez.initiateP2PSell(msg.sender, creatorId, sellingAmount, steezAmount);
		
	}
	function returnSellers(string memory creatorId) public view returns (Seller[] memory) {
		return s.sellers[creatorId];
	}
	function P2PBuy( string memory creatorId, uint256 buyingPrice, uint256 buyingAmount) public {
		LibSteez.P2PBuy(msg.sender, creatorId, buyingPrice, buyingAmount);
	}

	function anniversaryStarter(string memory creatorId) public {
		LibSteez.anniversaryStarter(creatorId);

	}

	function bidAnniversary(string memory creatorId, uint256 amount) public payable {		
		LibSteez.bidAnniversary(msg.sender, creatorId, amount);
	}

	function createCreator(string memory profileId) public payable {		
		LibSteez.createCreator(msg.sender, profileId);
	}

	function checkPreOrderStatus(string memory creatorId) public view returns (uint256, uint256 , uint256, uint256, uint256) {
		return ( s.steez[creatorId].SteeloInvestors[msg.sender], s.balances[msg.sender], s.steez[creatorId].totalSteeloPreOrder , s.steezInvested[msg.sender][creatorId], s.steez[creatorId].liquidityPool );
	}

	function PreOrderEnded(string memory creatorId) public view returns (bool) {
		return ( s.steez[creatorId].preOrderEnded);
	}

	function FirstAndLast(string memory creatorId) public view returns (uint256, uint256) {
		return (s.steez[creatorId].investors[0].steeloInvested, s.steez[creatorId].investors[s.steez[creatorId].investors.length - 1].steeloInvested);
	}

	function getCreatorWithId( string memory creatorId) public view returns (Creator memory, uint256, uint256) {
		return (s.creators[creatorId], s.steez[creatorId].currentPrice, s.steez[creatorId].investors.length);
	}

	function getAllCreatorsData() public view returns (CreatorSteez[] memory) {
		return (s.allCreators);
	}

	



}
