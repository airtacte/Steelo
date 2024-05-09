// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import {LibSteez} from "../libraries/LibSteez.sol";
import {AppConstants} from "../libraries/LibAppStorage.sol";
import {Steez, Content} from "../libraries/LibAppStorage.sol";


contract STEEZ8Facet {
   
	AppStorage internal s;

   
    	

	

		
	function createContent(string memory videoId, bool exclusivity) public payable {		
		LibSteez.createContent(msg.sender, videoId, exclusivity);
	}

	function getOneCreatorContent(string memory creatorId, string memory videoId) public view returns (Content memory) {
		require(keccak256(abi.encodePacked(s.creators[creatorId].creatorId)) != keccak256(abi.encodePacked("")), "there is no creator account");
		return s.creatorContent[creatorId][videoId];	
	}

	function getAllCreatorContents(string memory creatorId) public view returns (Content[] memory) {
		require(keccak256(abi.encodePacked(s.creators[creatorId].creatorId)) != keccak256(abi.encodePacked("")), "there is no creator account");
		return s.creatorCollections[creatorId];	
	}

	function getAllContents() public view returns (Content[] memory) {
		return s.collections;	
	}

	function deleteContent(string memory videoId) public payable {		
		LibSteez.deleteContent(msg.sender, videoId);
	}

	

	


}
