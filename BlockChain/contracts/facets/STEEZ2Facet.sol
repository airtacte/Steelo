// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibSteez} from "../libraries/LibSteez.sol";
import {AppConstants, Seller, Steez, Creator, CreatorSteez} from "../libraries/LibAppStorage.sol";


contract STEEZ2Facet {
   
	AppStorage internal s;

	

	


	
    	
	function bidLaunch(string memory creatorId, uint256 amount) public payable {		
		LibSteez.bidLaunch(msg.sender, creatorId, amount);
	}
	


	

	

	
	
	

	



}
