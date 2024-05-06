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

	function createSteeloUser() public {
		LibSteelo.createSteeloUser(msg.sender);
	}

	function steezStatus(string memory creatorId) public view returns (string memory) {
		return s.steez[creatorId].status;
	}
	

	


}
