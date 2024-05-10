// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibSteez} from "../libraries/LibSteez.sol";
import {AppConstants, Seller, Steez, Creator, CreatorSteez} from "../libraries/LibAppStorage.sol";


contract STEEZ3Facet {
   
	AppStorage internal s;

	
	
	

	

	

	function createCreator(string memory profileId) public payable {		
		LibSteez.createCreator(msg.sender, profileId);
	}

	function checkPreOrderStatus(string memory creatorId) public view returns (uint256, uint256 , uint256, uint256, uint256) {
		return ( s.steez[creatorId].SteeloInvestors[msg.sender], s.balances[msg.sender], s.steez[creatorId].totalSteeloPreOrder , s.steezInvested[msg.sender][creatorId], s.steez[creatorId].liquidityPool );
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

	function getAllCreator(string memory creatorId) public view returns (address, uint256, uint256 ) {
		return (s.steez[creatorId].creatorAddress, s.steez[creatorId].totalSupply, s.steez[creatorId].currentPrice );
	}

	function getAllCreator2(string memory creatorId) public view returns (uint256, uint256, bool ) {
		return (s.steez[creatorId].auctionStartTime, s.steez[creatorId].anniversaryDate, s.steez[creatorId].auctionConcluded );
	}

	function getAllCreator3(string memory creatorId) public view returns (uint256, uint256, bool ) {
		return (s.steez[creatorId].preOrderStartTime, s.steez[creatorId].liquidityPool, s.steez[creatorId].preOrderStarted );
	}

	function checkInvestorsLength(string memory creatorId) public view returns (uint256) {
		return s.steez[creatorId].investors.length;
	}

	function checkBidAmount(string memory creatorId) public view returns (uint256, uint256, uint256, uint256 ) {
		return (s.steez[creatorId].SteeloInvestors[msg.sender], s.steez[creatorId].liquidityPool, s.steez[creatorId].auctionSlotsSecured, s.steez[creatorId].totalSteeloPreOrder );
	}

	function checkInvestors(string memory creatorId) public view returns (uint256, uint256, uint256, address ) {
		return s.steez[creatorId].investors.length > 0
        		? (s.steez[creatorId].investors.length, 
           		s.steez[creatorId].investors[0].steeloInvested, 
           		s.steez[creatorId].investors[0].timeInvested, 
           		s.steez[creatorId].investors[0].walletAddress)
        		: (0, 0, 0, address(0));
	}

	

	

	

	function PreOrderEnder(string memory creatorId) public {
		LibSteez.PreOrderEnder( creatorId );
		
	}
	
	

	



}
