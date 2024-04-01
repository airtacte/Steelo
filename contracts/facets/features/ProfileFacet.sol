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
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

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
    event SafeCreated(address indexed userAddress, address safeAddress);
    event LensProfileCreated(address indexed userAddress, uint256 profileId);
    event SafeLinkedToProfile(address indexed userAddress, address safeAddress);
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

        lens = ILensHub(_lensAddress);
        safe = ISafe(_safeAddress);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Function to ensure a user has a Safe and Lens profile, and creates them if not
    function createUserProfile() public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address userAddress = msg.sender;
        // Check and create Safe if necessary
        if (userSafes[userAddress] == address(0)) {
            // Adjusted to call the createSafeWithOwners function from MultiSigFacet
            address[] memory owners = new address[](1);
            owners[0] = userAddress; // User is the sole owner of their Safe
            uint256 threshold = 1; // For simplicity, setting threshold to 1
            address safeAddress = multiSigFacet.createSafeWithOwners(
                owners,
                threshold
            );
            userSafes[userAddress] = safeAddress;
            emit SafeCreated(userAddress, safeAddress);
        }
        // Check and create Lens profile if necessary
        if (ds.profiles[profileId] == 0) {
            uint256 profileId = lensHub.createProfile(userAddress);
            ds.profiles[profileId] = profileId;
            emit LensProfileCreated(userAddress, profileId);
        }
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
        address userAddress = msg.sender;
        require(userSafes[userAddress] == address(0), "Safe already linked");
        userSafes[userAddress] = safeAddress;
        // You can add logic to verify ownership of the Safe if necessary
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

    // Getter function to retrieve a user's Safe address
    function getUserSafe(address userAddress) public view returns (address) {
        return userSafes[userAddress];
    }

    // Function to retrieve a user's profile
    function getProfile(address profileId) internal view {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.profiles[profileId];
    }

    // Function to execute a transaction from a user's Safe
    function executeUserTransaction(
        address safeAddress,
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        bytes calldata signatures
    ) public payable returns (bool) {
        // This function needs to construct the transaction and execute it through the user's Safe
        // Assuming SafeL2 or a similar contract is used that supports execTransaction
        SafeL2 safe = SafeL2(safeAddress);
        return
            safe.execTransaction(
                to,
                value,
                data,
                Enum.Operation(operation),
                safeTxGas,
                baseGas,
                gasPrice,
                gasToken,
                payable(refundReceiver),
                signatures
            );
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
        // Ensure the caller owns the profile
        require(
            userProfileIds[msg.sender] == profileId,
            "Caller does not own the profile"
        );
        // Call the LensHub contract to post content
        lensHub.postContent(profileId, contentUri);
    }

    // Function to follow another user's Lens profile
    function followProfile(uint256 profileIdToFollow) public {
        uint256 followerProfileId = userProfileIds[msg.sender];
        // Ensure the caller has a Lens profile
        require(followerProfileId != 0, "Caller does not have a Lens profile");
        // Call the LensHub contract to follow the profile
        lensHub.followProfile(followerProfileId, profileIdToFollow);
    }

    // Function to like a post on the Lens Protocol
    function likePost(uint256 postId) public {
        // Ensure the caller has a Lens profile
        require(
            userProfileIds[msg.sender] != 0,
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
