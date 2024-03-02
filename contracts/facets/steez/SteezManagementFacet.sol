// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { STEEZFacet } from "./STEEZFacet.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract SteezManagementFacet is AccessControlUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event BaseURIUpdated(string baseURI);
    event MaxCreatorTokensUpdated(uint256 maxTokens);
    event CreatorAddressUpdated(uint256 indexed tokenId, address indexed newCreatorAddress);
    event CreatorSplitUpdated(uint256 indexed tokenId, uint256[] newSplits);
    event TokenHoldersUpdated(uint256 indexed tokenId, address[] tokenHolders, uint256[] shares);
    event DistributionPolicyUpdated(uint256 indexed tokenId);
    event Paused();
    event Unpaused();

    mapping(uint256 => uint256[]) public creatorSplits;
    mapping (address => bool) private admins;
    mapping (address => bool) private creators;
    mapping (address => bool) private owners; // to rename to investors
    mapping (address => bool) private users;

    function initialize(address owner) public initializer {
        __AccessControl_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        super._setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        super._setupRole(MANAGER_ROLE, msg.sender);
        super._setupRole(PAUSER_ROLE, msg.sender);
    }

        // Update the base URI for token metadata
        function setBaseURI(string memory newBaseURI) public onlyRole(MANAGER_ROLE) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.baseURI = newBaseURI;
            emit BaseURIUpdated(newBaseURI);
        }

        // Retrieve the current base URI
        function baseURI() public view returns (string memory) {
            return LibDiamond.diamondStorage().baseURI;
        }

        // Update the creator's address for a specific token
        function updateCreatorAddress(uint256 tokenId, address newCreatorAddress) external onlyRole(MANAGER_ROLE) {
            require(newCreatorAddress != address(0), "New creator address cannot be zero address");
            require(tokenId > 0, "Token ID must be positive");

            STEEZFacet.Steez storage localSteez = STEEZFacet(address(this)).creatorSteez(newCreatorAddress);
            localSteez.creatorId = tokenId;

            emit CreatorAddressUpdated(tokenId, newCreatorAddress);
        }

        // Retrieve the current creator address for a specific token
        function getCreatorAddress(uint256 tokenId) public view returns (address) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            for (uint i = 0; i < creators.length; i++) {
                if (STEEZFacet(creators[i]).creatorSteez(creators[i]).creatorId == tokenId) {
                    return creators[i];
                }
            }
            return address(0); // return zero address if no creator found for the given tokenId
        }

        // Update the revenue or royalty split for a specific token
        function setCreatorSplit(uint256 tokenId, uint256[] memory splits) external onlyRole(MANAGER_ROLE) {
            uint256 total = 0;
            for (uint256 i = 0; i < splits.length; i++) {
                total += splits[i];
                require(splits[i] > 0, "Split must be positive");
            }
            require(total == 100, "Total split must be 100");

            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.creatorSplits[tokenId] = splits;
            emit CreatorSplitUpdated(tokenId, splits);
            emit DistributionPolicyUpdated(tokenId);
        }

        // Set token holders and their respective shares for a specific token
        function setTokenHolders(uint256 tokenId, address[] memory _tokenHolders, uint256[] memory shares) external onlyRole(MANAGER_ROLE) {
            require(_tokenHolders.length == shares.length, "Arrays must have the same length");
            uint256 total = 0;
            for (uint256 i = 0; i < shares.length; i++) {
                total += shares[i];
            require(_tokenHolders[i] != address(0), "Holder address cannot be zero");
            require(shares[i] > 0, "Share must be positive");
        }
            require(total == 100, "Total shares must be 100");

            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.tokenHolders[tokenId] = _tokenHolders;
            ds.communitySplits[tokenId] = shares;
            emit TokenHoldersUpdated(tokenId, _tokenHolders, shares);
        }

        // Check if the given token exists and returns an array of unique addresses that hold the token
        function getHolders(uint256 tokenId) public view returns (address[] memory) {
            require(_exists(tokenId), "CreatorToken: Token does not exist");
            return LibDiamond.diamondStorage().tokenHolders[tokenId];
        }

        // Pause function
        function pause() public onlyRole(PAUSER_ROLE) {
            _pause();
            emit Paused();
        }

        // Unpause function
        function unpause() public onlyRole(PAUSER_ROLE) {
            _unpause();
            emit Unpaused();
        }

        // Fallback function
        receive() external payable {}

        // Helper function to check if an address is already a creator
        function _isCreator(address profileAddress) private view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            STEEZFacet.Steez storage localSteez = STEEZFacet(address(this)).creatorSteez(profileAddress);
            return localSteez.creatorExists;
        }
        // Ensure the token exists
        function _exists(uint256 tokenId) private view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            return ds.tokenExists[tokenId];
        }
}