// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IProfileFacet } from "../../interfaces/IFeaturesFacet.sol";
import { ILensHub } from "../../../lib/lens-protocol/contracts/interfaces/ILensHub.sol";
import { STEEZFacet } from "../steez/STEEZFacet.sol";
import { ISafe } from "../../../lib/safe-contracts/contracts/interfaces/ISafe.sol";
import { SafeProxyFactory } from "../../../lib/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import { SafeL2 } from "../../../lib/safe-contracts/contracts/SafeL2.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract ProfileFacet is IProfileFacet, ERC1155Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address profileFacetAddress;
    STEEZFacet steezFacet;

    struct ProfileList {
        string username;
        string bio;
        string avatarURI;
        address walletAddress;
    }

    struct ContentList {
        uint256 contentId;
        address creator;
        bool isPublic;
    }

    struct CreatorList {
        uint256 creatorId;
        address creator;
        uint256 totalEarnings;
        uint256 totalInvestments;
        uint256 totalFollowers;
    }
    
    struct InvestorList {
        address creator;
        address[] investors;
    }

    struct OwnedSteez {
        uint256 tokenId;
        address creator;
    }

    struct PortfolioList {
        OwnedSteez[] ownedSteez;
    }

    struct ContributorList {
        uint256 contentId;
        address contributor;
        uint256 earnings;
    }

    struct SpaceData {
        uint256 spaceId;
        address creator;
        uint256[] contentIds;
    }

    event ProfileUpdated(address indexed user);
    event ContentPosted(address indexed user, uint256 contentId);
    event InvestorAdded(address indexed creator, address indexed investor);
    event PortfolioUpdated(address indexed user, uint256 indexed tokenId, uint256 amount);
    event SpaceCreated(address indexed user, uint256 spaceId);

    mapping(string => bool) usernameExists;
    mapping(address => ProfileList) profiles;
    mapping(uint256 => CreatorList) analytics;
    mapping(uint256 => ContentList) contents;
    mapping(address => InvestorList) investors;
    mapping(address => PortfolioList) portfolios;
    mapping(uint256 => ContributorList) contributors;
    mapping(uint256 => SpaceData) spaces;

    ILensHub lens;
    ISafe safe;

    function initialize() external {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        profileFacetAddress = ds.profileFacetAddress;
        ds.contractOwner = msg.sender;
    }

    function initialize(address _lensAddress, address _safeAddress) external initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init();
        __ReentrancyGuard_init();

        lens = ILensHub(_lensAddress);
        safe = ISafe(_safeAddress);
    }

        // Function to set up or update a user profile
        function setProfile(address user, string memory username, string memory bio, string memory avatarURI) external nonReentrant {
            LibDiamond.enforceIsContractOwner();
            require(!usernameTaken(username), "Username already taken");
            profiles[user] = ProfileList(username, bio, avatarURI, user);
            usernameExists[username] = true;
            emit ProfileUpdated(user);
        }

        function verifyCreator(uint256 creatorId) public {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        STEEZFacet.Steez memory localSteez = STEEZFacet(ds.steezFacetAddress).steez(creatorId);
            // Verification logic here

            localSteez.creatorId++; // Increment the creatorId
            localSteez.steez[creatorId]; // new Creator
        }

        // Function to check if a username already exists
        function usernameTaken(string memory username) internal view returns (bool) {
            return usernameExists[username];
        }

        // Function to retrieve a user's profile
        function getProfile(address user) internal view returns (ProfileList memory) {
            return profiles[user];
        }

        // Function to post content, with privacy settings
        function postContent(uint256 contentId, bool isPublic) external nonReentrant {
            lens.postContent(msg.sender, contentId, isPublic);
            emit ContentPosted(msg.sender, contentId);
        }

        // Function to add an investor to a creator's profile
        function addInvestor(address investor) external nonReentrant {
            _addInvestor(msg.sender, investor);
            // Needs to check if new investor actually owns their STEEZ
            emit InvestorAdded(msg.sender, investor);
        }

        // Function to update the portfolio of STEEZ tokens a user owns
        function updatePortfolio(uint256 tokenId, uint256 amount) external nonReentrant {
            _updatePortfolio(msg.sender, tokenId, amount);
            emit PortfolioUpdated(msg.sender, tokenId, amount);
        }

        // Function to create a Playlist Space
        function createSpace(uint256[] calldata contentIds) external nonReentrant {
            uint256 spaceId = _createSpace(msg.sender, contentIds);
            emit SpaceCreated(msg.sender, spaceId);
        }

        // Function to view a user's profile
        function viewProfile(address user) external view returns (ProfileList memory) {
            return profiles[user];
        }

        // Function to view content by ID
        function viewContent(uint256 contentId) external view returns (ContentList memory) {
            return contents[contentId];
        }

        // Function to get a list of investors for a creator
        function viewInvestors(address creator) external view returns (address[] memory) {
            return STEEZFacet.investors[creator];
        }

        // Function to view the portfolio of STEEZ tokens a user owns
        function viewPortfolio(address user) external view returns (PortfolioList[] memory) {
            return portfolios[user];
        }

        // Function to view a Space and its contents
        function viewSpace(uint256 spaceId) external view returns (SpaceData memory) {
            return spaces[spaceId];
        }

        function _addInvestor(address creator, address investor) internal {
            // implementation here
        }

        function _updatePortfolio(address user, uint256 tokenId, uint256 amount) internal {
            // implementation here
        }

        function _createSpace(address creator, uint256[] calldata contentIds) internal returns (uint256) {
            // implementation here
        }

        // Additional helper functions as needed for accessing nested or complex data structures
}