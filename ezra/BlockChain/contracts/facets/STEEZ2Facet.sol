// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibSteez} from "../libraries/LibSteez.sol";
import {AppConstants, Seller} from "../libraries/LibAppStorage.sol";


contract STEEZ2Facet {
   
	AppStorage internal s;


	function launchStarter(uint256 creatorId) public {
		LibSteez.launchStarter(creatorId);
	}
    	
	function bidLaunch(uint256 creatorId, uint256 amount) public payable {		
		LibSteez.bidLaunch(msg.sender, creatorId, amount);
	}
	function initiateP2PSell(uint256 creatorId, uint256 sellingAmount, uint256 steezAmount) public {
		LibSteez.initiateP2PSell(msg.sender, creatorId, sellingAmount, steezAmount);
		
	}
	function returnSellers(uint256 creatorId) public view returns (Seller[] memory) {
		return s.sellers[creatorId];
	}
	function P2PBuy( uint256 creatorId, uint256 buyingPrice, uint256 buyingAmount) public {
		LibSteez.P2PBuy(msg.sender, creatorId, buyingPrice, buyingAmount);
	}

	function anniversaryStarter(uint256 creatorId) public {
		LibSteez.anniversaryStarter(creatorId);

	}

	function bidAnniversary(uint256 creatorId, uint256 amount) public payable {		
		LibSteez.bidAnniversary(msg.sender, creatorId, amount);
	}



}
