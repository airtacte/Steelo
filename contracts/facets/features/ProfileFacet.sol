// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "../app/AccessControlFacet.sol";
import {MultiSigFacet} from "../app/MultiSigFacet.sol";
import {ILensHub} from "../../../lib/lens-protocol/contracts/interfaces/ILensHub.sol";
import {ISafe} from "../../../lib/safe-contracts/contracts/interfaces/ISafe.sol";
import {SafeProxyFactory} from "../../../lib/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import {SafeL2} from "../../../lib/safe-contracts/contracts/SafeL2.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import {Enum} from "../../../lib/safe-contracts/contracts/libraries/Enum.sol";

contract ProfileFacet is ERC1155Upgradeable, AccessControlFacet {
    address profileFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet public accessControl;
    ISafe private safe;
    ILensHub private lensHub;

    mapping(address => address) private userSafes;

    constructor(
        address _accessControlFacetAddress,
        address _safeAddress,
        address _lensHubAddress
    ) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
        safe = ISafe(_safeAddress);
        lensHub = ILensHub(_lensHubAddress);
    }

    event ProfileUpdated(address indexed profileId);
    event ContentPosted(address indexed profileId, uint256 contentId);
    event InvestorAdded(address indexed creator, address indexed investor);
    event SpaceCreated(address indexed profileId, uint256 spaceId);
    event SafeCreated(address indexed walletAddress, address safeAddress);
    event LensProfileCreated(address indexed walletAddress, uint256 profileId);
    event SafeLinkedToProfile(
        address indexed walletAddress,
        address safeAddress
    );
    event PortfolioUpdated(
        address indexed profileId,
        uint256 indexed tokenId,
        uint256 amount
    );

    function initialize(
        address _lensAddress,
        address _safeAddress
    ) external onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        profileFacetAddress = ds.profileFacetAddress;

        __ERC1155_init("https://myapi.com/api/token/{id}.json");

        lensHub = ILensHub(_lensAddress);
        safe = ISafe(_safeAddress);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Function to ensure a user has a Safe and Lens profile, and creates them if not
    function createUserProfile() public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        MultiSigFacet multiSig = MultiSigFacet(ds.multiSigFacetAddress);
        LensFacet lensFacet = LensFacet(ds.lensFacetAddress);
        address walletAddress = msg.sender;
        // Check and create Safe if necessary
        if (userSafes[walletAddress] == address(0)) {
            // Adjusted to call the createSafeWithOwners function from MultiSigFacet
            address[] memory owners = new address[](1);
            owners[0] = walletAddress; // User is the sole owner of their Safe
            uint256 threshold = 1; // For simplicity, setting threshold to 1
            address safeAddress = multiSig.createSafeWithOwners(
                owners,
                threshold
            );
            userSafes[walletAddress] = safeAddress;
            emit SafeCreated(walletAddress, safeAddress);
        }
        if (userLens[walletAddress] == address(0)) {
            // Check and create Lens profile if necessary via LensFacet
            lensFacet.createProfile(walletAddress);
        }
        // Check and create Lens profile if necessary via LensFacet
            emit LensProfileCreated(walletAddress, profileId);
    }

    // Function to set up or update a user profile
    function updateProfile(
        address profileId,
        bool verified,
        string memory walletAddress,
        string memory avatarURI,
        string memory username
    ) external onlyRole(accessControl.USER_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(!usernameTaken(username), "Username already taken");
        //ds.profiles[profileId] = ProfileList(username, bio, avatarURI, user);
        // check ifExists ds.profiles[username] = true;
        emit ProfileUpdated(profileId);
    }

    // Function to link an existing Safe with the user's Lens profile
    function linkSafeToProfile(address safeAddress) public {
        address walletAddress = msg.sender;
        require(userSafes[walletAddress] == address(0), "Safe already linked");
        userSafes[walletAddress] = safeAddress;
        // You can add logic to verify ownership of the Safe if necessary
    }

    function verifyCreator(uint256 creatorId) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // Verification logic here

        ds.creators[creatorId].creatorId++;
    }

    // Function to check if a username already exists
    function usernameTaken(
        string memory username
    ) internal view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // return usernameExists[username]; // Check if username exists
    }

    // Getter function to retrieve a user's Safe address
    function getUserSafe(address walletAddress) public view returns (address) {
        return userSafes[walletAddress];
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

    // Function to post content to a user's Lens profile
    function postContent(
        uint256 profileId,
        string calldata contentUri
    ) public onlyRole(accessControl.CREATOR_ROLE()) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // Ensure the caller owns the profile
        require(
            ds.profileIds[msg.sender] == ds.profileId,
            "Caller does not own the profile"
        );
        // Call the LensHub contract to post content
        lensHub.postContent(profileId, contentUri);
    }

    // Function to follow another user's Lens profile
    function followProfile(uint256 profileIdToFollow) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 followerProfileId = ds.profileIds[msg.sender];
        // Ensure the caller has a Lens profile
        require(followerProfileId != 0, "Caller does not have a Lens profile");
        // Call the LensHub contract to follow the profile
        lensHub.followProfile(followerProfileId, profileIdToFollow);
    }

    // Function to like a post on the Lens Protocol
    function likePost(uint256 postId) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // Ensure the caller has a Lens profile
        require(
            ds.profileIds[msg.sender] != 0,
            "Caller does not have a Lens profile"
        );
        // Call the LensHub contract to like the post
        lensHub.likePost(postId);
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
    // Additional functions for interacting with the Safe & Lens Protocol
    // Additional user profile management functionalities...
}