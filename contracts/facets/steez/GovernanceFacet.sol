// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { STEEZFacet } from "./STEEZFacet.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { BazaarFacet } from "../features/BazaarFacet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract GovernanceFacet is Initializable, OwnableUpgradeable {
    address governanceFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    // Events for tracking actions within the contract
    event ProposalCreated(uint256 indexed proposalId, string description);
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support);
    event ProposalExecuted(uint256 indexed proposalId);

    mapping(address => address) public voteDelegations;

    function initialize(address steezTokenAddress) public initializer {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        governanceFacetAddress = ds.governanceFacetAddress;
        
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    }

        function proposeBenefitChangeWithMetadata(
            string memory benefitDescription, 
            bytes memory callData, 
            string memory metadataURI
        ) public {
            uint256 proposalId = _propose(callData, benefitDescription);

            ds.proposal.benefitDescription = benefitDescription;
            ds.proposal.callData = callData;
            ds.proposal.metadataURI = metadataURI;

            emit ProposalCreated(proposalId, benefitDescription);
        }

        function createTimelockedProposal(
            bytes memory callData,
            string memory benefitDescription,
            uint256 unlockTime
        ) public {
            uint256 proposalId = _propose(callData, benefitDescription);
            // Time-locked proposal creation logic here involving unlockTime
            emit ProposalCreated(proposalId, benefitDescription);
        }

        function proposeCategoryChange(
            string memory category,
            bytes memory callData
        ) public {
            uint256 proposalId = _propose(callData, category);
            // Category change logic here
            emit ProposalCreated(proposalId, category);
        }

        // Voting on proposals
        function voteOnProposal(uint256 proposalId, bool support) public {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            // Voting logic here
            if(support) {
                castVote(proposalId, 1); // 1 for support
            } else {
                castVote(proposalId, 0); // 0 for against
            }
            emit VoteCast(msg.sender, proposalId, support);
        }

        function checkProposalQuorum(uint256 proposalId) public view returns (bool) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            // Check if the proposal has met the required quorum
            return hasMetQuorum(proposalId);
        }

        function hasMetQuorum(uint256 proposalId) private view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            uint256 totalVotes = ds.sips[proposalId].voteCountFor + ds.sips[proposalId].voteCountAgainst;
            uint256 quorumPercentage = ds.constants.QUORUM_PERCENTAGE; // Defined in your constants
            uint256 totalVotingPower = getTotalVotingPower(); // Implement this function based on your tokenomics
            return totalVotes >= (totalVotingPower * quorumPercentage / 100);
        }

        function delegateVote(address delegatee) public {
            require(delegatee != address(0), "Cannot delegate to zero address");
            voteDelegations[msg.sender] = delegatee;
        }

        // Use this in your vote counting logic to account for delegated votes
        function getVoterFor(address voter) public view returns (address) {
            return voteDelegations[voter] == address(0) ? voter : voteDelegations[voter];
        }

        // Execute approved proposals
        function executeProposal(uint256 proposalId) public {
            require(hasMetQuorum(proposalId), "Quorum not met");
            SIP storage sip = ds.sips[proposalId];
            require(!sip.executed, "Proposal already executed");
            
            (bool success, ) = address(this).delegatecall(sip.callData); // Ensure security around delegatecall usage
            require(success, "Proposal execution failed");
            
            sip.executed = true;
            emit ProposalExecuted(proposalId);
        }

        function getProposalHistory(uint256 proposalId) public view returns (Proposal memory) {
            // Fetch and return the history of a proposal
            return proposalHistory[proposalId];
        }

        // Propose a new proposal
        function propose(bytes memory callData, string memory benefitDescription) public returns (uint256) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            // Proposal logic here
            // ...
        }

        function cancelProposal(uint256 proposalId) public {
            // Proposal cancellation logic here
            cancel(proposalId);
            emit ProposalCancelled(proposalId);
        }

        function amendProposal(uint256 proposalId, string memory newDescription, bytes memory newCallData) public {
            // Proposal amendment logic here
            amend(proposalId, newDescription, newCallData);
            emit ProposalAmended(proposalId, newDescription);
        }

        // Cast a vote on a proposal
        function castVote(uint256 proposalId, uint8 vote) public {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            // Voting logic here
            // ...
        }

        // Execute a proposal
        function execute(uint256 proposalId) public {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            // Execution logic here
            // ...
        }

        // Add more functions as needed for managing governance within a creator's community
}