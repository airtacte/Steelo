    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./LibAppStorage.sol";
import {AppConstants} from "./LibAppStorage.sol";
import {Message} from "./LibAppStorage.sol";


library LibVillage {

	function sendMessage( uint256 creatorId, address sender, address recipient, string memory message) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(sender != address(0), "0 address can not create a steez");
		Message memory newMessage = Message({
				message: message,
				timeSent: block.timestamp
        	});
		s.p2pMessages[creatorId][sender][recipient].push(newMessage);
		if (s.contacts[creatorId][sender].length == 0) {
			s.contacts[creatorId][sender].push(recipient);	
		}
		else if (s.contacts[creatorId][sender].length > 0) {
			if (!exists(recipient, creatorId, sender)) {
            			s.contacts[creatorId][sender].push(recipient);
       			 }
		}


		if (s.contacts[creatorId][recipient].length == 0) {
			s.contacts[creatorId][recipient].push(sender);	
		}
		else if (s.contacts[creatorId][recipient].length > 0) {
			if (!exists(sender, creatorId, recipient)) {
            			s.contacts[creatorId][recipient].push(sender);
       			 }
		}
	}

	function exists( address contact, uint256 creatorId, address owner) private view returns (bool) {
		AppStorage storage s = LibAppStorage.diamondStorage();
        	for (uint i = 0; i < s.contacts[creatorId][owner].length; i++) {
         	   	if (s.contacts[creatorId][owner][i] == contact) {
         		       	return true;
         	   	}
        	}
        	return false;
    		}

	

}	
