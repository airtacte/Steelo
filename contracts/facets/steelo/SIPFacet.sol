// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "../app/AccessControlFacet.sol";
import {STEELOFacet} from "./STEELOFacet.sol";
import "hardhat/console.sol";

contract SIPFacet is AccessControlFacet {
    address sipFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl;

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    STEELOFacet steeloFacet; // Instance of the SteeloFacet

    event SIPCreated(
        uint256 indexed id,
        string description,
        string proposalType,
        address indexed proposer,
        uint256 startTime,
        uint256 endTime
    );
    event SIPVoted(
        uint256 indexed id,
        bool support,
        address indexed voter,
        uint256 weight
    );
    event SIPExecuted(uint256 indexed id, bool success);

    function initialize()
        public
        onlyRole(accessControl.EXECUTIVE_ROLE())
        initializer
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        sipFacetAddress = ds.sipFacetAddress;

        steeloFacet = STEELOFacet(ds.steeloFacetAddress);
    }

    function getProposerRole(
        address _proposer
    ) internal view returns (string memory) {
        if (accessControl.hasRole(accessControl.CREATOR_ROLE(), _proposer)) {
            return "creator";
        } else if (
            accessControl.hasRole(accessControl.USER_ROLE(), _proposer)
        ) {
            return "community";
        } else if (
            accessControl.hasRole(accessControl.EXECUTIVE_ROLE(), _proposer)
        ) {
            return "platform";
        }
        return "unknown";
    }

    function getProposalHash(
        uint256 proposalId
    ) public view returns (bytes memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.proposals[proposalId].proposalHashes[proposalId];
    }

    // When creating the SIP, store the role of the proposer
    function createSIP(
        string memory _title,
        string memory _description,
        uint256 _startTime,
        uint256 _endTime,
        address _proposer
    ) external onlyRole(accessControl.ADMIN_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 sipId = ds.lastSipId++;

        ds.sips[sipId].sipId = sipId;
        ds.sips[sipId].sipType = "YourProposalTypeHere"; // Replace with actual SIP type
        ds.sips[sipId].title = _title;
        ds.sips[sipId].description = _description;
        ds.sips[sipId].proposer = _proposer;
        ds.sips[sipId].proposerRole = getProposerRole(_proposer);
        ds.sips[sipId].startTime = _startTime;
        ds.sips[sipId].endTime = _endTime;
        ds.sips[sipId].executed = false;

        // Initialize vote counts to 0
        ds.sips[sipId].voteCountForSteelo = 0;
        ds.sips[sipId].voteCountAgainstSteelo = 0;
        ds.sips[sipId].voteCountForCreator = 0;
        ds.sips[sipId].voteCountAgainstCreator = 0;
        ds.sips[sipId].voteCountForCommunity = 0;
        ds.sips[sipId].voteCountAgainstCommunity = 0;

        // Store the role of the proposer
        ds.sips[sipId].proposerRole = getProposerRole(_proposer);

        // Store the role of the proposer
        if (accessControl.hasRole(accessControl.CREATOR_ROLE(), _proposer)) {
            ds.sips[sipId].proposerRole = "creator";
        } else if (
            accessControl.hasRole(accessControl.USER_ROLE(), _proposer)
        ) {
            ds.sips[sipId].proposerRole = "community";
        } else if (
            accessControl.hasRole(accessControl.EXECUTIVE_ROLE(), _proposer)
        ) {
            ds.sips[sipId].proposerRole = "platform";
        }

        emit SIPCreated(
            sipId,
            _description,
            "YourProposalTypeHere",
            _proposer,
            _startTime,
            _endTime
        );
    }

    // In the voteOnSIP function, double the vote count of the proposer's role
    function voteOnSIP(
        uint256 _sipId,
        bool _support
    ) external onlyRole(accessControl.STAKER_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_sipId < ds.lastSipId, "SIP does not exist");
        require(!ds.sips[_sipId].votes[msg.sender], "Already voted");
        require(
            block.timestamp >= ds.sips[_sipId].startTime &&
                block.timestamp <= ds.sips[_sipId].endTime,
            "Voting is not active"
        );

        // Classify votes based on the role of the voter
        if (accessControl.hasRole(accessControl.CREATOR_ROLE(), msg.sender)) {
            if (_support) {
                ds.sips[_sipId].voteCountForCreator += 1;
            } else {
                ds.sips[_sipId].voteCountAgainstCreator += 1;
            }
        } else if (
            accessControl.hasRole(accessControl.USER_ROLE(), msg.sender)
        ) {
            if (_support) {
                ds.sips[_sipId].voteCountForCommunity += 1;
            } else {
                ds.sips[_sipId].voteCountAgainstCommunity += 1;
            }
        } else if (
            accessControl.hasRole(accessControl.EXECUTIVE_ROLE(), msg.sender)
        ) {
            if (_support) {
                ds.sips[_sipId].voteCountForSteelo += 1;
            } else {
                ds.sips[_sipId].voteCountAgainstSteelo += 1;
            }
        }

        ds.sips[_sipId].votes[msg.sender] = true;

        emit SIPVoted(_sipId, _support, msg.sender, 1);

        // Check if the SIP has passed
        uint256 creatorVote = ds.sips[_sipId].voteCountForCreator >
            ds.sips[_sipId].voteCountAgainstCreator
            ? (
                keccak256(abi.encodePacked(ds.sips[_sipId].proposerRole)) ==
                    keccak256(abi.encodePacked("creator"))
                    ? 2
                    : 1
            )
            : 0;
        uint256 communityVote = ds.sips[_sipId].voteCountForCommunity >
            ds.sips[_sipId].voteCountAgainstCommunity
            ? (
                keccak256(abi.encodePacked(ds.sips[_sipId].proposerRole)) ==
                    keccak256(abi.encodePacked("community"))
                    ? 2
                    : 1
            )
            : 0;
        uint256 steeloVote = ds.sips[_sipId].voteCountForSteelo >
            ds.sips[_sipId].voteCountAgainstSteelo
            ? (
                keccak256(abi.encodePacked(ds.sips[_sipId].proposerRole)) ==
                    keccak256(abi.encodePacked("steelo"))
                    ? 2
                    : 1
            )
            : 0;

        if (creatorVote + communityVote + steeloVote >= 3) {
            // Verify the Steelo transaction
            bool isVerified = steeloFacet.verifyTransaction(_sipId);
            if (isVerified) {
                // Execute the SIP
                executeSIP(_sipId);
            }
        }
    }

    function executeSIP(
        uint256 _sipId
    ) public onlyRole(accessControl.ADMIN_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_sipId < ds.lastSipId, "SIP does not exist");
        require(
            ds.sips[_sipId].endTime < block.timestamp,
            "SIP voting period has not ended"
        );
        require(!ds.sips[_sipId].executed, "SIP already executed");

        bool success;
        string memory reason;

        // Execute the Diamond Cut or Upgradeable as proposed - To amend to manage without slowing STEELOFacet
        // (success, reason) = steeloFacet.executeProposal(_sipId);

        ds.sips[_sipId].executed = success;

        emit SIPExecuted(_sipId, success);
    }

    // Function to view SIP details
    function viewSIP(
        uint256 _sipId
    )
        public
        view
        returns (
            uint256 sipId,
            string memory title,
            string memory description,
            address proposer,
            string memory proposerRole,
            uint256 startTime,
            uint256 endTime,
            bool executed
        )
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.sips[_sipId].sipId != 0, "SIP does not exist");

        LibDiamond.SIP storage sip = ds.sips[_sipId];
        return (
            sip.sipId,
            sip.title,
            sip.description,
            sip.proposer,
            sip.proposerRole,
            sip.startTime,
            sip.endTime,
            sip.executed
        );
    }

    // Function to list all SIPs
    function listSIPs() public view returns (uint256[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.sipIds;
    }

    // Function to list all successful SIPs
    function listSuccessfulSIPs() public view returns (uint256[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256[] memory successfulSIPIds = new uint256[](ds.lastSipId); // Assuming lastSipId is a count of all SIPs
        uint256 count = 0;
        for (uint256 i = 0; i < ds.lastSipId; i++) {
            if (ds.sips[i].executed) {
                successfulSIPIds[count] = i;
                count++;
            }
        }
        // Return a new array with the exact size of successful SIP IDs
        uint256[] memory trimmedArray = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            trimmedArray[i] = successfulSIPIds[i];
        }
        return trimmedArray;
    }

    // Function to get total SIPs
    function getTotalSIPs() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.sipIds.length; // This line will not work as 'sips' is a mapping, not an array
    }

    // Function to get total SIPs
    function getTotalSuccessfulSIPs() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 count = 0;
        for (uint256 i = 1; i <= ds.lastSipId; i++) {
            if (ds.sips[i].executed) {
                count++;
            }
        }
        return count;
    }

    function getVoteCount(uint256 _sipId) public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.sips[_sipId].sipId != 0, "SIP does not exist");
        return
            ds.sips[_sipId].voteCountForSteelo +
            ds.sips[_sipId].voteCountForCreator +
            ds.sips[_sipId].voteCountForCommunity;
    }

    function isSIPActive(uint256 _sipId) public view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_sipId < ds.lastSipId, "SIP does not exist");
        return
            block.timestamp >= ds.sips[_sipId].startTime &&
            block.timestamp <= ds.sips[_sipId].endTime;
    }

    function isSIPExecuted(uint256 _sipId) public view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_sipId < ds.lastSipId, "SIP does not exist");
        return ds.sips[_sipId].executed;
    }

    // Function to check the balance of the treasury
    function getTreasuryBalance(address _token) public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.treasury[_token];
    }

    // Function to deposit funds into the treasury
    function depositToTreasury(
        uint256 _amount
    ) external onlyRole(accessControl.ADMIN_ROLE()) nonReentrant {
        steeloFacet.transferFrom(msg.sender, address(this), _amount);
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.treasury[address(STEELOFacet(ds.steeloFacetAddress))] += _amount;
    }

    // Function to withdraw funds from the treasury
    function withdrawFromTreasury(
        uint256 _amount
    ) external onlyRole(accessControl.ADMIN_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(
            ds.treasury[address(STEELOFacet(ds.steeloFacetAddress))] >= _amount,
            "Insufficient funds in treasury"
        );
        ds.treasury[address(STEELOFacet(ds.steeloFacetAddress))] -= _amount;
        steeloFacet.transfer(msg.sender, _amount);
    }
}
