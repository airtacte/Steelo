// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import {LibSteelo} from "../libraries/LibSteelo.sol";
import {AppConstants} from "../libraries/LibAppStorage.sol";


contract STEELO4Facet {
   
	AppStorage internal s;

   
	

	

	function steeloPrice() public view returns (uint256) {
		return s.steeloCurrentPrice;	
	}

	function createSteeloUser(string memory profileId) public {
		LibSteelo.createSteeloUser(msg.sender, profileId);
	}

	function steezStatus(string memory creatorId) public view returns (string memory) {
		return s.steez[creatorId].status;
	}

	function profileIdUser() public view returns (string memory) {
		return s.userIdentity[msg.sender];
	}

	function profileIdCreator() public view returns (string memory) {
		return s.creatorIdentity[msg.sender];
	}

	function isExecutive() public view returns (bool) {
		return s.executiveMembers[msg.sender];
	}
	

	


}
