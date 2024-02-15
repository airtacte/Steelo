// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SteezGovernanceFacet is Initializable, AccessControlUpgradeable, GovernorUpgradeable, GovernorVotesUpgradeable {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    // Events for tracking actions within the contract
    event ProposalCreated(uint256 proposalId, string description);
    event VoteCast(address voter, uint256 proposalId, bool support);
    event ProposalExecuted(uint256 proposalId);

    function initialize(address steezTokenAddress) public initializer {
        __AccessControl_init();
        __Governor_init("SteezGovernanceFacet");
        __GovernorVotes_init(steezTokenAddress); // Initialize with the Steez token address implementing IVotes
        
        // Set up roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MODERATOR_ROLE, msg.sender);

        // Granting the contract itself a moderator role allows internal functions to manage governance actions
        _setupRole(MODERATOR_ROLE, address(this));
    }

    // Example: Propose a new benefit for Steez token holders
    function proposeBenefitChange(string memory benefitDescription, bytes memory callData) public onlyRole(DEFAULT_ADMIN_ROLE) {
        // Only the default admin can propose changes
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not the admin");

        // Proposal creation logic here
        // For simplicity, we're directly interacting with a hypothetical IGovernor interface
        // In practice, you'd need to adapt this to your governance process
        uint256 proposalId = governor.propose(callData, benefitDescription);
        emit ProposalCreated(proposalId, benefitDescription);
    }

    // Voting on proposals
    function voteOnProposal(uint256 proposalId, bool support) public {
        // Ensure only Steez token holders can vote
        require(_isSteezTokenHolder(msg.sender), "Must be a Steez token holder to vote");

        // Voting logic here
        if(support) {
            governor.castVote(proposalId, 1); // 1 for support
        } else {
            governor.castVote(proposalId, 0); // 0 for against
        }
        emit VoteCast(msg.sender, proposalId, support);
    }

    // Execute approved proposals
    function executeProposal(uint256 proposalId) public {
        // Only a moderator can execute proposals
        require(hasRole(MODERATOR_ROLE, msg.sender), "Caller is not a moderator");

        // Execution logic here
        governor.execute(proposalId);
        emit ProposalExecuted(proposalId);
    }

    // Utility function to check if an address holds any Steez tokens
    function _isSteezTokenHolder(address account) private view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 tokenIdForGovernance = 1; // Example tokenId used for governance
        uint256 balance = ds.steezFacet.balanceOf(account, tokenIdForGovernance);
        
        return balance > 0;
    }

    // Add more functions as needed for managing governance within a creator's community
}