// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibVillage} from "../libraries/LibVillage.sol";
import {AppConstants, Message} from "../libraries/LibAppStorage.sol";

contract VillageFacet {
   
	AppStorage internal s;

	function sendMessage(string memory creatorId, address recipient, string memory message) public {
		LibVillage.sendMessage( creatorId, msg.sender, recipient, message);
	}

	function getChat(string memory creatorId, address recipient) public view returns (Message[] memory, Message[] memory) {
		return ( 
			s.p2pMessages[creatorId][msg.sender][recipient],
			s.p2pMessages[creatorId][recipient][msg.sender]
		       );		
	}

	function getContacts(string memory creatorId) public view returns (address[] memory) {
		return s.contacts[creatorId][msg.sender];
	}

	function deleteMessage(string memory creatorId, address recipient, uint256 messageId) public {
		LibVillage.deleteMessage( creatorId, msg.sender, recipient, messageId);
	}

	function editMessage(string memory creatorId, address recipient, uint256 messageId, string memory message) public {
		LibVillage.editMessage( creatorId, msg.sender, recipient, messageId, message);
	}
	function postMessage(string memory creatorId, string memory message) public {
		LibVillage.postMessage( creatorId, msg.sender, message);
	}

	function getGroupChat(string memory creatorId) public view returns (Message[] memory) {
		return s.posts[creatorId];		
	}

	function deleteGroupMessage(string memory creatorId, uint256 messageId) public {
		LibVillage.deleteGroupMessage( creatorId, msg.sender, messageId);
	}
	function editGroupMessage(string memory creatorId, uint256 messageId, string memory message) public {
		LibVillage.editGroupMessage( creatorId, msg.sender, messageId, message);
	}
	



}
