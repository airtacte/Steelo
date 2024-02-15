// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IAppFacet } from  "../../interfaces/IAppFacet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SteeloGovernanceFacet is IGovernanceFacet, Initializable, OwnableUpgradeable {
    using LibDiamond for LibDiamond.DiamondStorage;

    event SIPCreated(uint256 indexed sipId, SIPType indexed sipType, address indexed proposer, string description);
    event SIPVoted(uint256 indexed sipId, address indexed voter, bool vote);
    event SIPExecuted(uint256 indexed sipId, bool executed);

    enum SIPType { Platform, Creator, Investor }

    struct SIP {
        SIPType sipType;
        string description;
        address proposer;
        uint256 voteCountFor;
        uint256 voteCountAgainst;
        bool executed;
        mapping(address => bool) votes;
    }

    mapping(uint256 => SIP) public sips;
    uint256 public sipCount;

    modifier onlyStakeholders() {
        require(SteeloStakingFacet(address(this)).isStakeholder(msg.sender), "Not a stakeholder");
        _;
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    function createSIP(SIPType _sipType, string memory _description) external onlyStakeholders returns (uint256) {
        SIP storage newSIP = sips[++sipCount];
        newSIP.sipType = _sipType;
        newSIP.description = _description;
        newSIP.proposer = msg.sender;
        
        emit SIPCreated(sipCount, _sipType, msg.sender, _description);
        return sipCount;
    }

    function voteOnSIP(uint256 _sipId, bool _voteFor) external onlyStakeholders {
        SIP storage sip = sips[_sipId];
        require(!sip.votes[msg.sender], "Already voted");

        uint256 voteWeight = 1;
        if (msg.sender == sip.proposer && sip.sipType == SIPType.Creator) {
            voteWeight = 2;
        }

        sip.votes[msg.sender] = true;
        if (_voteFor) {
            sip.voteCountFor += voteWeight;
        } else {
            sip.voteCountAgainst += voteWeight;
        }

        emit SIPVoted(_sipId, msg.sender, _voteFor);
    }

    function checkForExecution(uint256 _sipId) internal {
        SIP storage sip = sips[_sipId];
        uint256 totalVotes = sip.voteCountFor + sip.voteCountAgainst;
        require(totalVotes >= 4, "Insufficient votes");

        // Execute SIP if the majority is achieved considering the initiator's double vote
        if (sip.voteCountFor >= 3) {
            executeSIP(_sipId); // Assuming executeSIP function exists and handles SIP execution
        }
    }

    function executeSIP(uint256 _sipId) external onlyOwner {
        SIP storage sip = sips[_sipId];
        require(!sip.executed, "SIP already executed");
        
        // Example condition for execution, this should be replaced with actual logic
        if (sip.voteCountFor > sip.voteCountAgainst) {
            // Execute SIP logic based on SIPType
            sip.executed = true;
            emit SIPExecuted(_sipId, true);
        } else {
            emit SIPExecuted(_sipId, false);
        }
    }

    // Add more governance functions as needed...
}
