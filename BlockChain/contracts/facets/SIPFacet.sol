// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {LibSIP} from "../libraries/LibSIP.sol";
import {AppConstants, SIP, Voter} from "../libraries/LibAppStorage.sol";

contract SIPFacet {
   
	AppStorage internal s;

	function proposeSIP(string memory title, string memory description, string memory sipType) public {
		LibSIP.propose(msg.sender, title, description, sipType);
		
	}

	function getSIPProposal(uint256 sipId) public view returns (SIP memory) {
		return s.sips[sipId];
	}

	function getAllSIPProposal() public view returns (SIP[] memory) {
		return s.allSIPs;
	}



	function registerVoter(uint256 sipId) public {
		LibSIP.register(msg.sender, sipId);

	}

	function getVoter(uint256 sipId) public view returns (Voter memory) {
		return s.votes[sipId][msg.sender];
	}


	function voteOnSip(uint256 sipId, bool vote) public {
		LibSIP.voteOnSip(msg.sender, sipId, vote);
		
	}

	function SIPTimeEnder(uint256 sipId) public {
		LibSIP.SIPTimeEnder(sipId);

	}

	function roleChanger(uint256 sipId) public {
		LibSIP.roleChanger(sipId, msg.sender);

	}



}
