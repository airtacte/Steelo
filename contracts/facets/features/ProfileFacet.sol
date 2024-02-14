// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity 0.8.20;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IProfileFacet } from "../../interfaces/IFeaturesFacet.sol";
import { ILens } from "../../interfaces/ILens.sol";
import { ISafe } from "../../../lib/safe-contracts/contracts/interfaces/ISafe.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../app/MultiSigFacet.sol";

contract ProfileFacet is IProfileFacet, ERC1155Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    struct ProfileInfo {
        string username;
        string bio;
        string avatarURI;
        address walletAddress;
    }

    struct OwnedSteez {
        uint256 tokenId;
        address creator;
    }

    struct PortfolioData {
        OwnedSteez[] ownedSteez;
    }

    event ProfileUpdated(address indexed user);
    event ContentPosted(address indexed user, uint256 contentId);
    event InvestorAdded(address indexed creator, address indexed investor);
    event PortfolioUpdated(address indexed user, uint256 indexed tokenId, uint256 amount);
    event SpaceCreated(address indexed user, uint256 spaceId);

    mapping(string => bool) usernameExists;
    mapping(address => ProfileInfo) profiles;
    mapping(uint256 => CreatorData) analytics;
    mapping(uint256 => ContentList) contents;
    mapping(address => InvestorList) investors;
    mapping(address => PortfolioList) portfolios;
    mapping(uint256 => ContributorData) contributors;
    mapping(uint256 => SpaceData) spaces;

    ILens lens;
    ISafe safe;

    function initialize() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;
    }

    function initialize(address _lensAddress, address _safeAddress) external initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init();
        __ReentrancyGuard_init();

        lens = ILens(_lensAddress);
        safe = ISafe(_safeAddress);
    }

        // Function to set up or update a user profile
        function setProfile(address user, string memory username, string memory bio, string memory avatarURI) external override nonReentrant {
            LibDiamond.enforceIsContractOwner();
            require(!usernameTaken(username), "Username already taken");
            profiles[user] = ProfileInfo(username, bio, avatarURI, user);
            usernameExists[username] = true;
            emit ProfileUpdated(user);
        }

        // Function to check if a username already exists
        function usernameTaken(string memory username) internal view returns (bool) {
            return usernameExists[username];
        }

        // Function to retrieve a user's profile
        function getProfile(address user) internal view returns (ProfileInfo memory) {
            return profiles[user];
        }

        // Function to post content, with privacy settings
        function postContent(uint256 contentId, bool isPublic) external override nonReentrant {
            lens.postContent(msg.sender, contentId, isPublic);
            emit ContentPosted(msg.sender, contentId);
        }

        // Function to add an investor to a creator's profile
        function addInvestor(address investor) external override nonReentrant {
            _addInvestor(msg.sender, investor);
            // Needs to check if new investor actually owns their STEEZ
            emit InvestorAdded(msg.sender, investor);
        }

        // Function to update the portfolio of STEEZ tokens a user owns
        function updatePortfolio(uint256 tokenId, uint256 amount) external override nonReentrant {
            _updatePortfolio(msg.sender, tokenId, amount);
            emit PortfolioUpdated(msg.sender, tokenId, amount);
        }

        // Function to create a Playlist Space
        function createSpace(uint256[] calldata contentIds) external override nonReentrant {
            uint256 spaceId = _createSpace(msg.sender, contentIds);
            emit SpaceCreated(msg.sender, spaceId);
        }

        // Function to view a user's profile
        function viewProfile(address user) external view returns (ProfileData memory) {
            return profiles[user];
        }

        // Function to view content by ID
        function viewContent(uint256 contentId) external view returns (ContentData memory) {
            return contents[contentId];
        }

        // Function to get a list of investors for a creator
        function viewInvestors(address creator) external view returns (address[] memory) {
            return STEEZFacet.investors[creator];
        }

        // Function to view the portfolio of STEEZ tokens a user owns
        function viewPortfolio(address user) external view returns (STEEZFacet.PortfolioData[] memory) {
            return STEEZFacet.portfolios[user];
        }

        // Function to view a Space and its contents
        function viewSpace(uint256 spaceId) external view returns (SpaceData memory) {
            return spaces[spaceId];
        }

        // Additional helper functions as needed for accessing nested or complex data structures
}