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

	function getChat(uint256 creatorId, address recipient) public view returns (Message[] memory) {
		return s.p2pMessages[creatorId][msg.sender][recipient];		
	}

	function getContacts(uint256 creatorId) public view returns (address[] memory) {
		return s.contacts[creatorId][msg.sender];
	}
	



}
