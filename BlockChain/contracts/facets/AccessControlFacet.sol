// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibAccessControl} from "../libraries/LibAccessControl.sol";
import {AppConstants, Message} from "../libraries/LibAppStorage.sol";

contract AccessControlFacet {
   
	AppStorage internal s;

	function initialize() public {
		LibAccessControl.initialize(msg.sender);	
	}

	function getRole() public view returns (string memory) {
		return s.roles[msg.sender];
	}

	function getPower() public view returns (bool) {
		return s.adminMembers[msg.sender];
	}
	function grantRole(string memory role, address account) public {
		LibAccessControl.grantRole(msg.sender, role, account);	
	}

	function revokeRole(string memory role, address account) public {
		LibAccessControl.revokeRole(msg.sender, role, account);	
	}
	



}
