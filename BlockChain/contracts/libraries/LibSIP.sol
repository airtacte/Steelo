    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./LibAppStorage.sol";
import {AppConstants, SIP, Voter} from "./LibAppStorage.sol";


library LibSIP {

	function propose(address proposer, string memory title, string memory description, string memory sipType) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		uint256 sipId = ++s._lastSIPId;
		SIP memory newSIP = SIP({
				sipId: sipId,
				sipType: sipType,
				title: title,
				description: description,
				proposer: proposer,
				proposerRole: "creator",
				voteCountForSteelo: 0,
				voteCountAgainstSteelo: 0,
				voteCountForCreator: 0,
				voteCountAgainstCreator: 0,
				voteCountForCommunity: 0,
				voteCountAgainstCommunity: 0,
				startTime: block.timestamp,
				endTime: block.timestamp + 30 days,
				executed: false,
				status: "onVote"
        	});
		s.sips[sipId] = newSIP;
		s.allSIPs.push(newSIP);
	}


	function register(address voter, uint256 sipId) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.sips[sipId].proposer != address(0), "there is no proposal with this SIP id");
		require(s.votes[sipId][voter].voter == address(0), "you are already registered to vote");
		require(!s.sips[sipId].executed, "SIP has already been executed");
		Voter memory newVoter = Voter({
			voted: false,
			vote: false,
			voter: voter,
			role: "user"
        	});
		s.votes[sipId][voter] = newVoter;
	}

	function voteOnSip (address voter, uint256 sipId, bool vote) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.sips[sipId].proposer != address(0), "there is no proposal with this SIP id");
		require(!s.sips[sipId].executed, "SIP has already been executed");
		require(s.userMembers[voter] == true, "at lease you must have an account to vote");
		if (block.timestamp >= s.sips[sipId].endTime) {
			initiateSIPApproval(sipId);
		}
		if (!s.sips[sipId].executed) { 
			require(s.votes[sipId][voter].voter != address(0), "you have not registered to vote");
			require(s.votes[sipId][voter].voted == false, "you have already voted for this SIP");
			
			
			if (keccak256(abi.encodePacked(s.votes[sipId][voter].role)) == keccak256(abi.encodePacked("creator"))) {
	  			if (vote == true) {
					s.sips[sipId].voteCountForCreator += 1;
				} else {
					s.sips[sipId].voteCountAgainstCreator += 1;
				}
			}
			else if (keccak256(abi.encodePacked(s.votes[sipId][voter].role)) == keccak256(abi.encodePacked("staff"))) {
				if (vote == true) {
					s.sips[sipId].voteCountForSteelo += 1;
				} else {
					s.sips[sipId].voteCountAgainstSteelo += 1;
				}
			}
			else if (keccak256(abi.encodePacked(s.votes[sipId][voter].role)) == keccak256(abi.encodePacked("user"))) {
				if (vote == true) {
					s.sips[sipId].voteCountForCommunity += 1;
				} else {
					s.sips[sipId].voteCountAgainstCommunity += 1;
				}
			}
			s.votes[sipId][voter].voted = true;
		}

	}

	function initiateSIPApproval(uint256 sipId) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		uint256 TotalVote = 0;
		if (s.sips[sipId].voteCountForCreator > s.sips[sipId].voteCountAgainstCreator) {
			TotalVote += 1;
		}
		if (s.sips[sipId].voteCountForSteelo > s.sips[sipId].voteCountAgainstSteelo) {
			TotalVote += 1;
		}
		if (s.sips[sipId].voteCountForCommunity > s.sips[sipId].voteCountAgainstCommunity) {
			TotalVote += 1;
		}

		if (TotalVote >= 2) {
			s.sips[sipId].status = "approved";
		}
		else {
			s.sips[sipId].status = "declined";	
		}
		s.sips[sipId].executed = true;
		
	}

	function SIPTimeEnder(uint256 sipId) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.sips[sipId].endTime -= 30 days;	
	}

	function roleChanger(uint256 sipId, address voter) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.sips[sipId].proposer != address(0), "there is no proposal with this SIP id");
		require(s.votes[sipId][voter].voter != address(0), "you have not registered to vote");
		s.votes[sipId][voter].role = "creator";
	}

}	
