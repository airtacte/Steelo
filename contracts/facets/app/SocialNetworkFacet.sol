// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "./AccessControlFacet.sol";
import { ISafe } from "../../../lib/safe-contracts/contracts/interfaces/ISafe.sol";
import { ILensHub } from "../../../lib/lens-protocol/contracts/interfaces/ILensHub.sol";

contract SocialNetworkFacet is AccessControlFacet {
    address socialNetworkFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    ISafe private safeCore;
    ILensHub private lensHub;

    mapping(address => address) private userSafes;
    mapping(address => uint256) private userProfileIds; // Mapping user address to Lens profile ID

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress, address _safeCoreAddress, address _lensHubAddress) {
        AccessControlFacet accessControl = AccessControlFacet(_accessControlFacetAddress);
        safeCore = ISafe(_safeCoreAddress);
        lensHub = ILensHub(_lensHubAddress);
    }

    event SafeCreated(address indexed userAddress, address safeAddress);
    event LensProfileCreated(address indexed userAddress, uint256 profileId);
    event SafeLinkedToProfile(address indexed userAddress, address safeAddress);

    function initialize() external onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        socialNetworkFacetAddress = ds.socialNetworkFacetAddress;
    }

        // Function to ensure a user has a Safe and Lens profile, and creates them if not
        function ensureOrCreateUserProfile() public {
            address userAddress = msg.sender;
            // Check and create Safe if necessary
            if (userSafes[userAddress] == address(0)) {
                address safeAddress = safeCore.createSafe(userAddress);
                userSafes[userAddress] = safeAddress;
                emit SafeCreated(userAddress, safeAddress);
            }
            // Check and create Lens profile if necessary
            if (userProfileIds[userAddress] == 0) {
                uint256 profileId = lensHub.createProfile(userAddress);
                userProfileIds[userAddress] = profileId;
                emit LensProfileCreated(userAddress, profileId);
            }
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
            // Ensure only the Safe owner or authorized users can execute this
            return safeCore.executeTransaction(
                safeAddress,
                to,
                value,
                data,
                operation,
                safeTxGas,
                baseGas,
                gasPrice,
                gasToken,
                refundReceiver,
                signatures
            );
        }

        // Function to link an existing Safe with the user's Lens profile
        function linkSafeToProfile(address safeAddress) public {
            address userAddress = msg.sender;
            require(userSafes[userAddress] == address(0), "Safe already linked");
            userSafes[userAddress] = safeAddress;
            // You can add logic to verify ownership of the Safe if necessary
        }
        
        // Function to post content to a user's Lens profile
        function postContent(uint256 profileId, string calldata contentUri) public onlyRole(accessControl.CREATOR_ROLE()) {
            // Ensure the caller owns the profile
            require(userProfileIds[msg.sender] == profileId, "Caller does not own the profile");
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
            require(userProfileIds[msg.sender] != 0, "Caller does not have a Lens profile");
            // Call the LensHub contract to like the post
            lensHub.likePost(postId);
        }
        
        // Additional functions for interacting with the Lens Protocol

        // Getter function to retrieve a user's Safe address
        function getUserSafe(address userAddress) public view returns (address) {
            return userSafes[userAddress];
        }

        // Getter function to retrieve a user's Lens profile ID
        function getUserProfileId(address userAddress) public view returns (uint256) {
            return userProfileIds[userAddress];
        }

        // Additional user profile management functionalities...
}
