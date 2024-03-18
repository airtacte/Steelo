// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { STEEZFacet } from "./STEEZFacet.sol";
import { BazaarFacet } from "../features/BazaarFacet.sol";

contract GovernanceFacet is AccessControlFacet {
    address governanceFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}

    // Events for tracking actions within the contract
    event ProposalCreated(uint256 id, address proposer, string description, bytes callData);
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support);
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCancelled(uint256 indexed proposalId);
    event ProposalAmended(uint256 indexed proposalId, string newDescription);

    mapping(address => address) public voteDelegations;

    
    function initialize(address steezTokenAddress) public onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        governanceFacetAddress = ds.governanceFacetAddress;
    }

        function proposeBenefitChange(
            string memory benefits, 
            bytes memory callData, 
            string memory metadataURI
        ) public {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            uint256 proposalId = _propose(callData, benefits);

            ds.proposal.benefits = benefits;
            ds.proposal.callData = callData;
            ds.proposal.metadataURI = metadataURI;

            emit ProposalCreated(proposalId, benefits);
        }

        function createTimelockedProposal(
            bytes memory callData,
            string memory benefits,
            uint256 unlockTime
        ) public {
            uint256 proposalId = _propose(callData, benefits);
            // Time-locked proposal creation logic here involving unlockTime
            emit ProposalCreated(proposalId, benefits);
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
        function voteOnProposal(uint256 proposalId, bool support) public onlyRole(accessControl.INVESTOR_ROLE()) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            // Voting logic here
            if(support) {
                castVote(proposalId, 1); // 1 for support
            } else {
                castVote(proposalId, 0); // 0 for against
            }
            emit VoteCast(msg.sender, proposalId, support);
        }

        function checkProposalQuorum(uint256 proposalId) public view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
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

        function getTotalVotingPower(uint256 profileId) public view returns (uint256) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            return ds.profiles[profileId].stakingBalance;
        }

        function delegateVote(address delegatee) public onlyRole(accessControl.INVESTOR_ROLE()) {
            require(delegatee != address(0), "Cannot delegate to zero address.");
            voteDelegations[msg.sender] = delegatee;
        }

        // Use this in your vote counting logic to account for delegated votes
        function getVoterFor(address voter) public view returns (address) {
            return voteDelegations[voter] == address(0) ? voter : voteDelegations[voter];
        }

        // Execute approved proposals
        function executeProposal(uint256 proposalId) public onlyRole(accessControl.CREATOR_ROLE()) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(hasMetQuorum(proposalId), "Quorum not met.");
            require(!ds.sips.executed, "Proposal already executed.");
            
            (bool success, ) = address(this).delegatecall(ds.proposals.callData); // Ensure security around delegatecall usage
            require(success, "Proposal execution failed.");
            
            ds.sips.executed = true;
            emit ProposalExecuted(proposalId);
        }

        function getProposalHistory(uint256 proposalId) public view returns (
            address proposer,
            uint256 startBlock,
            uint256 endBlock,
            string memory benefits,
            bytes memory callData,
            string memory metadataURI,
            bool executed,
            uint256 forVotes,
            uint256 againstVotes
        ) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            LibDiamond.Proposal memory proposal = ds.proposalHistory[proposalId];

            return (
                proposal.proposalId,
                proposal.proposer,
                proposal.startBlock,
                proposal.endBlock,
                proposal.benefits,
                proposal.callData,
                proposal.metadataURI,
                proposal.executed,
                proposal.forVotes,
                proposal.againstVotes
            );
        }

        function _propose(bytes memory callData, string memory benefits, string memory metadataURI) public onlyRole(accessControl.INVESTOR_ROLE()) returns (uint256) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

            // Increment the proposal count to get a new proposal ID
            ds.proposalCount++;

            // Create a new proposal
            LibDiamond.Proposal memory newProposal;
            newProposal.proposalId = ds.proposalCount;
            newProposal.proposer = msg.sender;
            newProposal.startBlock = block.number;
            newProposal.endBlock = block.number + ds.votingPeriod;
            newProposal.benefits = benefits;
            newProposal.callData = callData;
            newProposal.metadataURI = metadataURI;
            newProposal.executed = false;
            newProposal.forVotes = 0;
            newProposal.againstVotes = 0;

            // Add the new proposal to the proposal history
            ds.proposalHistory[ds.proposalCount] = newProposal;

            // Emit a ProposalCreated event
            emit ProposalCreated(ds.proposalCount, msg.sender, benefits, callData, metadataURI);

            return ds.proposalCount;
        }

        function cancelProposal(uint256 proposalId) public onlyRole(accessControl.MODERATOR_ROLE()) {
            // Proposal cancellation logic here
            emit ProposalCancelled(proposalId);
        }

        function amendProposal(uint256 proposalId, string memory newDescription, bytes memory newCallData) public onlyRole(accessControl.MODERATOR_ROLE()) {
            // Proposal amendment logic here
            emit ProposalAmended(proposalId, newDescription);
        }

        // Cast a vote on a proposal
        function castVote(uint256 proposalId, uint8 vote) public onlyRole(accessControl.INVESTOR_ROLE()) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            LibDiamond.Proposal storage proposal = ds.proposalHistory[proposalId];

            require(proposal.proposer != address(0), "Proposal does not exist");
            require(proposal.executed == false, "Proposal already executed");
            require(vote == 0 || vote == 1, "Invalid vote value");

            uint256 votingPower = getTotalVotingPower(msg.sender);

            if (vote == 1) {
                proposal.forVotes += votingPower;
            } else {
                proposal.againstVotes += votingPower;
            }

            emit VoteCast(msg.sender, proposalId, vote == 1);
        }

        // Execute a proposal
        function execute(uint256 proposalId) public {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            // Execution logic here
            // ...
        }

        // Add more functions as needed for managing governance within a creator's community
}