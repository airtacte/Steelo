// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "../app/AccessControlFacet.sol";
import {ILensHub} from "../../../lib/lens-protocol/contracts/interfaces/ILensHub.sol";
import {ISafe} from "../../../lib/safe-contracts/contracts/interfaces/ISafe.sol";
import {SafeProxyFactory} from "../../../lib/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import {SafeL2} from "../../../lib/safe-contracts/contracts/SafeL2.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

contract ProfileFacet is ERC1155Upgradeable, AccessControlFacet {
    address profileFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    event ProfileUpdated(address indexed profileId);
    event ContentPosted(address indexed profileId, uint256 contentId);
    event InvestorAdded(address indexed creator, address indexed investor);
    event PortfolioUpdated(
        address indexed profileId,
        uint256 indexed tokenId,
        uint256 amount
    );
    event SpaceCreated(address indexed profileId, uint256 spaceId);

    ILensHub lens;
    ISafe safe;

    function initialize(
        address _lensAddress,
        address _safeAddress
    ) external onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        profileFacetAddress = ds.profileFacetAddress;

        __ERC1155_init("https://myapi.com/api/token/{id}.json");

        lens = ILensHub(_lensAddress);
        safe = ISafe(_safeAddress);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Function to set up or update a user profile
    function setProfile(
        address profileId,
        string memory profileIdname,
        string memory bio,
        string memory avatarURI,
        string memory username
    ) external onlyRole(accessControl.USER_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(!usernameTaken(username), "Username already taken");
        //ds.profiles[profileId] = ProfileList(username, bio, avatarURI, user);
        // check ifExists ds.profiles[username] = true;
        emit ProfileUpdated(profileId);
    }

    function verifyCreator(uint256 creatorId) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // Verification logic here

        ds.steez.creatorId++; // Increment the creatorId
        ds.steez.steez[creatorId]; // new Creator
    }

    // Function to check if a username already exists
    function usernameTaken(
        string memory username
    ) internal view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // return usernameExists[username]; // Check if username exists
    }

    // Function to retrieve a user's profile
    function getProfile(address profileId) internal view {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.profiles[profileId];
    }

    // Function to add an investor to a creator's profile
    function addInvestor(
        address investor
    ) external onlyRole(accessControl.CREATOR_ROLE()) nonReentrant {
        _addInvestor(msg.sender, investor);
        // Needs to check if new investor actually owns their STEEZ
        emit InvestorAdded(msg.sender, investor);
    }

    // Function to update the portfolio of STEEZ tokens a profileId owns
    function updatePortfolio(
        uint256 tokenId,
        uint256 amount
    ) external onlyRole(accessControl.CREATOR_ROLE()) nonReentrant {
        _updatePortfolio(msg.sender, tokenId, amount);
        emit PortfolioUpdated(msg.sender, tokenId, amount);
    }

    // Function to create a Playlist Space
    function createSpace(
        uint256[] calldata contentIds
    ) external onlyRole(accessControl.CREATOR_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.spaceId = _createSpace(msg.sender, ds.contentIds);
        emit SpaceCreated(msg.sender, ds.spaceId);
    }

    // Function to view a profileId's profile
    function viewProfile(address profileId) external view {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.profiles[profileId];
    }

    // Function to view content by ID
    function viewContent(uint256 contentId) external view {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.content[contentId];
    }

    // Function to get a list of investors for a creator
    function viewInvestors(
        address creator
    ) external view returns (address[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.steez.investors[creator];
    }

    // Function to view the portfolio of STEEZ tokens a profileId owns
    function viewPortfolio(address profileId) external view {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.portfolios[profileId];
    }

    // Function to view a Space and its content
    function viewSpace(
        uint256 spaceId
    ) external view onlyRole(accessControl.USER_ROLE()) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.spaces[spaceId];
    }

    function _addInvestor(address creator, address investor) internal {
        // implementation here
    }

    function _updatePortfolio(
        address profileId,
        uint256 tokenId,
        uint256 amount
    ) internal {
        // implementation here
    }

    function _createSpace(
        address creator,
        uint256[] calldata contentIds
    ) internal returns (uint256) {
        // implementation here
    }

    // Additional helper functions as needed for accessing nested or complex data structures
}
