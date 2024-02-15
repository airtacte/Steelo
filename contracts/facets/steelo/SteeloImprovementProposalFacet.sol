// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "hardhat/console.sol";

contract SteeloImprovementProposalFacet is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    struct SIP {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        address proposer;
        bool executed;
        uint256 yesVotes;
        uint256 noVotes;
        ProposalType proposalType;
    }

    enum ProposalType {CreatorInitiated, InvestorInitiated, SteeloInitiated}

    SIP[] public sips;

    event SIPCreated(uint256 indexed id, string description, ProposalType proposalType, address indexed proposer);
    event SIPVoted(uint256 indexed id, bool support, address indexed voter, uint256 weight);
    event SIPExecuted(uint256 indexed id, bool success);

    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function createSIP(string memory _description, ProposalType _type, uint256 _duration) external onlyOwner {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _duration;
        uint256 newSipId = sips.length;
        SIP storage newSIP = sips.push();
        newSIP.id = newSipId;
        newSIP.description = _description;
        newSIP.startTime = startTime;
        newSIP.endTime = endTime;
        newSIP.proposer = msg.sender;
        newSIP.proposalType = _type;
        emit SIPCreated(newSipId, _description, _type, msg.sender, startTime, endTime);
    }

    function voteOnSIP(uint256 _sipId, bool _support) external nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 weight = ds.getVoterWeight(msg.sender);
        ds.voteOnSIP(_sipId, msg.sender, _support, weight);
        emit SIPVoted(_sipId, _support, msg.sender, weight);
    }

    function executeSIP(uint256 _sipId) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.sips[_sipId].endTime < block.timestamp, "SIP voting period has not ended");
        require(_sipId < sips.length, "SIP does not exist");
        SIP storage sip = sips[_sipId];
        require(!sip.executed, "SIP already executed");

        (bool success, string memory reason) = ds.executeSIP(_sipId);

        // Example condition for execution; replace with actual logic specific to the SIP
        if (sip.voteCountFor > sip.voteCountAgainst) {
            sip.executed = true;
            emit SIPExecuted(_sipId, success, reason);
        } else {
            emit SIPExecuted(_sipId, failure, reason);
        }
    }

    // Additional functions for voting, managing SIPs, etc., can be added here
}