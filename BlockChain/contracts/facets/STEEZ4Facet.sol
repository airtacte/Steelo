// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibSteez} from "../libraries/LibSteez.sol";
import {AppConstants, Seller, Steez, Creator, CreatorSteez} from "../libraries/LibAppStorage.sol";


contract STEEZ4Facet {
   
	AppStorage internal s;

		

	function deleteCreator(string memory profileId) public payable {		
		LibSteez.deleteCreator(msg.sender, profileId);
	}

	function returnSteezTransaction(string memory profileId) public view returns (uint256) {
		return s.totalSteezTransaction[profileId];
	}

	function createSteez( ) public {
		LibSteez.createSteez( msg.sender );
    	}

	

	function initializePreOrder(string memory creatorId ) public payable {
		LibSteez.preOrder( creatorId, msg.sender );
    	}

	


		
	

	function steezInitiate () public returns (bool success) {
		LibSteez.initiate(msg.sender);
		return true;
	}

	
	function creatorTokenName () public view returns (string memory) {
		return s.creatorTokenName;
	}

	
    	function launchStarter(string memory creatorId) public {
		LibSteez.launchStarter(creatorId);
	}

	function anniversaryStarter(string memory creatorId) public {
		LibSteez.anniversaryStarter(creatorId);

	}
	
	
	function initiateP2PSell(string memory creatorId, uint256 sellingAmount, uint256 steezAmount) public {
		LibSteez.initiateP2PSell(msg.sender, creatorId, sellingAmount, steezAmount);
		
	}
	function returnSellers(string memory creatorId) public view returns (Seller[] memory) {
		return s.sellers[creatorId];
	}

	

	



}
