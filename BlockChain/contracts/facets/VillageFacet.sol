// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibVillage} from "../libraries/LibVillage.sol";
import {AppConstants, Message} from "../libraries/LibAppStorage.sol";

contract VillageFacet {
   
	AppStorage internal s;

	function sendMessage(uint256 creatorId, address recipient, string memory message) public {
		LibVillage.sendMessage( creatorId, msg.sender, recipient, message);
	}

	function getChat(uint256 creatorId, address recipient) public view returns (Message[] memory, Message[] memory) {
		return ( 
			s.p2pMessages[creatorId][msg.sender][recipient],
			s.p2pMessages[creatorId][recipient][msg.sender]
		       );		
	}

	function getContacts(uint256 creatorId) public view returns (address[] memory) {
		return s.contacts[creatorId][msg.sender];
	}

	function deleteMessage(uint256 creatorId, address recipient, uint256 messageId) public {
		LibVillage.deleteMessage( creatorId, msg.sender, recipient, messageId);
	}

	function editMessage(uint256 creatorId, address recipient, uint256 messageId, string memory message) public {
		LibVillage.editMessage( creatorId, msg.sender, recipient, messageId, message);
	}
	function postMessage(uint256 creatorId, string memory message) public {
		LibVillage.postMessage( creatorId, msg.sender, message);
	}

	function getGroupChat(uint256 creatorId) public view returns (Message[] memory) {
		return s.posts[creatorId];		
	}

	function deleteGroupMessage(uint256 creatorId, uint256 messageId) public {
		LibVillage.deleteGroupMessage( creatorId, msg.sender, messageId);
	}
	function editGroupMessage(uint256 creatorId, uint256 messageId, string memory message) public {
		LibVillage.editGroupMessage( creatorId, msg.sender, messageId, message);
	}
	



}