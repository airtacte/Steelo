// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "../app/AccessControlFacet.sol";
import {STEEZFacet} from "./STEEZFacet.sol";

contract ManagementFacet is AccessControlFacet {
    address managementFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl;

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    event BaseURIUpdated(string baseURI);
    event MaxCreatorTokensUpdated(uint256 maxTokens);
    event CreatorAddressUpdated(
        uint256 indexed tokenId,
        address indexed newCreatorAddress
    );
    event CreatorSplitUpdated(uint256 indexed tokenId, uint256[] newSplits);
    event TokenHoldersUpdated(
        uint256 indexed tokenId,
        address[] tokenHolders,
        uint256[] shares
    );
    event DistributionPolicyUpdated(uint256 indexed tokenId);
    event Paused();
    event Unpaused();

    mapping(address => bool) private admins;
    mapping(address => bool) private creators;
    mapping(address => bool) private owners; // to rename to investors
    mapping(address => bool) private users;

    function initialize(
        address owner
    ) public onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        managementFacetAddress = ds.managementFacetAddress;
    }

    // Update the base URI for token metadata
    function setBaseURI(
        string memory newBaseURI
    ) public onlyRole(accessControl.CREATOR_ROLE()) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.baseURI = newBaseURI;
        emit BaseURIUpdated(newBaseURI);
    }

    // Retrieve the current base URI
    function baseURI() public view returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.baseURI;
    }

    // Update the creator's address for a specific token
    function updateCreatorAddress(
        uint256 tokenId,
        address newCreatorAddress
    ) external onlyRole(accessControl.CREATOR_ROLE()) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(
            newCreatorAddress != address(0),
            "New creator address cannot be zero address"
        );
        require(tokenId > 0, "Token ID must be positive");

        ds.steez.creatorId = tokenId;

        emit CreatorAddressUpdated(tokenId, newCreatorAddress);
    }

    // Retrieve the current creator address for a specific token
    function getCreatorAddress(uint256 tokenId) public view returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // Loop through all creatorIds in the allCreatorIds array
        for (uint i = 0; i < ds.allCreatorIds.length; i++) {
            // If the creatorId of the Steez at the current index matches the tokenId
            if (ds.steez[ds.allCreatorIds[i]].creatorId == tokenId) {
                // Return the address of the creator
                return ds.creators[ds.allCreatorIds[i]].profileAddress;
            }
        }
        return address(0); // return zero address if no creator found for the given tokenId
    }

    // Update the revenue or royalty split for a specific token
    function setCreatorSplit(
        uint256 tokenId,
        uint256[] memory splits
    ) external onlyRole(accessControl.CREATOR_ROLE()) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 total = 0;
        for (uint256 i = 0; i < splits.length; i++) {
            total += splits[i];
            require(splits[i] > 0, "Split must be positive");
        }
        require(total == 100, "Total split must be 100");

        ds.creatorSplits[tokenId] = splits;
        emit CreatorSplitUpdated(tokenId, splits);
        emit DistributionPolicyUpdated(tokenId);
    }

    // Set token holders and their respective shares for a specific token
    function setTokenHolders(
        uint256 tokenId,
        address[] memory _tokenHolders,
        uint256[] memory shares
    ) external onlyRole(accessControl.CREATOR_ROLE()) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(
            _tokenHolders.length == shares.length,
            "Arrays must have the same length"
        );
        uint256 total = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            total += shares[i];
            require(
                _tokenHolders[i] != address(0),
                "Holder address cannot be zero"
            );
            require(shares[i] > 0, "Share must be positive");
        }

        require(total == 100, "Total shares must be 100");

        ds.tokenHolders[tokenId] = _tokenHolders;
        ds.communitySplits[tokenId] = shares;
        emit TokenHoldersUpdated(tokenId, _tokenHolders, shares);
    }

    // Check if the given profile is an investor in the steez and returns an array of unique addresses that hold the steez
    function getHolders(
        uint256 profileId,
        uint256 steezId
    ) public view returns (address[] memory) {
        require(
            _isInvestorInSteez(profileId, steezId),
            "Profile is not an investor in the steez"
        );
        return LibDiamond.diamondStorage().tokenHolders[steezId];
    }

    // Pause function
    function pause() public onlyRole(accessControl.ADMIN_ROLE()) {
        _pause();
        emit Paused();
    }

    // Unpause function
    function unpause() public onlyRole(accessControl.ADMIN_ROLE()) {
        _unpause();
        emit Unpaused();
    }

    // Fallback function
    receive() external payable {}

    // Ensure the profile is an investor in the steez
    function _isInvestorInSteez(
        uint256 profileId,
        uint256 steezId
    ) private view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // Get the investor struct for the profile
        LibDiamond.Investor storage investor = ds.investors[
            ds.profiles[profileId].walletAddress
        ];

        // Check if the investor owns the steez
        return investor.portfolio[steezId].isInvestor;
    }
}
