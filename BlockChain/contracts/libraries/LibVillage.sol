    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./LibAppStorage.sol";
import {AppConstants} from "./LibAppStorage.sol";
import {Message} from "./LibAppStorage.sol";


library LibVillage {

	function sendMessage( string memory creatorId, address sender, address recipient, string memory message) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(sender != address(0), "0 address can not create a steez");
		s.messageCounter ++;
		Message memory newMessage = Message({
				id: s.messageCounter,
				message: message,
				sender: sender,
				recipient: recipient,
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

	function exists( address contact, string memory creatorId, address owner) private view returns (bool) {
		AppStorage storage s = LibAppStorage.diamondStorage();
        	for (uint i = 0; i < s.contacts[creatorId][owner].length; i++) {
         	   	if (s.contacts[creatorId][owner][i] == contact) {
         		       	return true;
         	   	}
        	}
        	return false;
    	}

	function deleteMessage( string memory creatorId, address sender, address recipient, uint256 messageId) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(sender != address(0), "0 address can not create a steez");
		uint length =  s.p2pMessages[creatorId][sender][recipient].length;
		for (uint i = 0; i < length; i++) {
         	   	if (s.p2pMessages[creatorId][sender][recipient][i].id == messageId) {
         		       s.p2pMessages[creatorId][sender][recipient][i] = s.p2pMessages[creatorId][sender][recipient][length - 1];
			       s.p2pMessages[creatorId][sender][recipient].pop();	
         	   	}
        	}
	
	}

	function editMessage( string memory creatorId, address sender, address recipient, uint256 messageId, string memory message) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(sender != address(0), "0 address can not create a steez");
		uint length =  s.p2pMessages[creatorId][sender][recipient].length;
		for (uint i = 0; i < length; i++) {
         	   	if (s.p2pMessages[creatorId][sender][recipient][i].id == messageId) {
         		       s.p2pMessages[creatorId][sender][recipient][i].message = message;
         	   	}
        	}
	
	}

	function postMessage( string memory creatorId, address sender, string memory message) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(sender != address(0), "0 address can not create a steez");
		s.messageCounter ++;
		Message memory newMessage = Message({
				id: s.messageCounter,
				sender: sender,
				recipient: s.steez[creatorId].creatorAddress,
				message: message,
				timeSent: block.timestamp
        	});
		s.posts[creatorId].push(newMessage);
		
	}

	function deleteGroupMessage( string memory creatorId, address sender, uint256 messageId) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(sender != address(0), "0 address can not create a steez");
		uint length =  s.posts[creatorId].length;
		for (uint i = 0; i < length; i++) {
         	   	if (s.posts[creatorId][i].id == messageId) {
         		       s.posts[creatorId][i] = s.posts[creatorId][length - 1];
			       s.posts[creatorId].pop();	
         	   	}
        	}
	
	}

	function editGroupMessage( string memory creatorId, address sender, uint256 messageId, string memory message) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(sender != address(0), "0 address can not create a steez");
		uint length =  s.posts[creatorId].length;
		for (uint i = 0; i < length; i++) {
         	   	if (s.posts[creatorId][i].id == messageId) {
         		       s.posts[creatorId][i].message = message;
         	   	}
        	}
	
	}

	

}	
