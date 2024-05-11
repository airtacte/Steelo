// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibSteez} from "../libraries/LibSteez.sol";


contract STEEZ5Facet {
   
	AppStorage internal s;

   

	

	function AcceptOrReject(string memory creatorId, bool answer) public {
		LibSteez.AcceptOrReject( msg.sender, creatorId, answer );
		
	}
	

	


}
