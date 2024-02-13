// SPDX-License-Identifier: MIT
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

string username;
string bio;
string avatarURI;
address walletAddress;

contract ProfileFacet is IProfileFacet, ERC1155Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    // Event declarations, e.g., for profile updates, content posted, etc.
    event ProfileUpdated(address indexed user);
    event ContentPosted(address indexed user, uint256 contentId);
    event InvestorAdded(address indexed creator, address indexed investor);
    event PortfolioUpdated(address indexed user, uint256 indexed tokenId, uint256 amount);
    event SpaceCreated(address indexed user, uint256 spaceId);

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
        function setProfile(LibDiamond.ProfileInput calldata profileInput) external override nonReentrant {
            LibDiamond.enforceIsContractOwner();
            LibDiamond.ProfileData storage profile = LibDiamond._setProfile(msg.sender, profileInput);
            emit ProfileUpdated(msg.sender);
        }

        // Function to post content, with privacy settings
        function postContent(uint256 contentId, bool isPublic) external override nonReentrant {
            lens.postContent(msg.sender, contentId, isPublic);
            emit ContentPosted(msg.sender, contentId);
        }

        // Function to add an investor to a creator's profile
        function addInvestor(address investor) external override nonReentrant {
            LibDiamond._addInvestor(msg.sender, investor);
            emit InvestorAdded(msg.sender, investor);
        }

        // Function to update the portfolio of STEEZ tokens a user owns
        function updatePortfolio(uint256 tokenId, uint256 amount) external override nonReentrant {
            LibDiamond._updatePortfolio(msg.sender, tokenId, amount);
            emit PortfolioUpdated(msg.sender, tokenId, amount);
        }

        // Function to create a Space
        function createSpace(uint256[] calldata contentIds) external override nonReentrant {
            uint256 spaceId = LibDiamond._createSpace(msg.sender, contentIds);
            emit SpaceCreated(msg.sender, spaceId);
        }

        // Function to view a user's profile
        function viewProfile(address user) external view returns (LibProfile.ProfileData memory) {
            return LibProfile.profiles[user];
        }

        // Function to view content by ID
        function viewContent(uint256 contentId) external view returns (LibProfile.ContentData memory) {
            return LibProfile.contents[contentId];
        }

        // Function to get a list of investors for a creator
        function viewInvestors(address creator) external view returns (address[] memory) {
            return LibProfile.investors[creator];
        }

        // Function to view the portfolio of STEEZ tokens a user owns
        function viewPortfolio(address user) external view returns (LibProfile.PortfolioData[] memory) {
            return LibProfile.portfolios[user];
        }

        // Function to view a Space and its contents
        function viewSpace(uint256 spaceId) external view returns (LibProfile.SpaceData memory) {
            return LibProfile.spaces[spaceId];
        }

        // Additional helper functions as needed for accessing nested or complex data structures
}