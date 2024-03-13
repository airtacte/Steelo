// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GalleryFacet is Initializable {
    address galleryFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;
    using Strings for uint256;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}

    modifier onlyExecutive() {
        require(accessControl.hasRole(accessControl.EXECUTIVE_ROLE(), msg.sender), "AccessControl: caller is not an executive");
        _;
    }

    // Initialize GalleryFacet setting the contract owner
    function initialize() external onlyExecutive initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        galleryFacetAddress = ds.galleryFacetAddress;
    }

    // Function to display owned NFTs with metadata
    function displayNFTs(address nftContract, uint256 tokenId) public view returns (string memory) {
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        // Placeholder for logic to retrieve and return NFT metadata
        // This could involve IPFS or another decentralized storage solution
        return "NFT Metadata URL";
    }

    // Simplified Steez management function
    // Action could be 'stake', 'unstake', 'buy', 'sell'
    function manageSteez(address tokenContract, uint256 tokenId, uint256 amount, string memory action) public {
        // Placeholder for token management logic
        // Specific logic will depend on the action parameter
    }

    // Function to view analytics about the user's NFT and Steez portfolio
    function viewPortfolioAnalytics() public view returns (string memory) {
        // Placeholder for analytics logic
        // Could return a summary of owned NFTs, Steezs, their current market value, and performance over time
        return "Portfolio Analytics Data";
    }

    // Additional recommended function: Transfer NFTs
    // Facilitate the transfer of NFTs directly from the user's gallery
    function transferNFT(address nftContract, uint256 tokenId, address to) public {
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        IERC721(nftContract).safeTransferFrom(msg.sender, to, tokenId);
    }

    // Additional recommended function: Transfer Steezs
    // Allow the management of Steezs (e.g., transfer to another address)
    function transferSteez(address tokenContract, uint256 tokenId, uint256 amount, address to) public {
        // Logic to transfer
    }
}