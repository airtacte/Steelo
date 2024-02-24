// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

interface ISteezFacet {
    // This event is emitted when royalties are set for a token
    event RoyaltySet(uint256 indexed tokenId, uint256 royalty);

    // This event is emitted when royalties are paid
    event RoyaltyPaid(uint256 indexed tokenId, address indexed payee, uint256 amount);

    // This event is emitted when the base URI is updated
    event BaseURIUpdated(string newBaseURI);

    // This event is emitted when ownership of a token is transferred
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, uint256 indexed tokenId);

    // This event is emitted when a token is minted
    event TokenMinted(uint256 indexed tokenId, address indexed to, uint256 amount);

    // This event is emitted when a token transfer occurs
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 value);

    // Set the contract address that will handle royalties
    function setRoyaltiesContract(address royaltiesContractAddress) external;

    // Set the maximum number of creator tokens that can be minted
    function setMaxCreatorTokens(uint256 maxTokens) external;

    // Get the maximum number of creator tokens that can be minted
    function getMaxCreatorTokens() external view returns (uint256);

    // Set the base URI for the token metadata
    function setBaseURI(string memory newBaseURI) external;

    // Get the base URI for the token metadata
    function baseURI() external view returns (string memory);

    // Transfer ownership of a token to another address
    function transferOwnership(address newOwner, uint256 tokenId) external;

    // Transfer tokens from one address to another
    function transferToken(uint256 id, uint256 value, address from, address to) external;

    // Mint new tokens
    function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) external;

    // This function handles the royalty payment logic
    function payRoyaltiesOnTransfer(uint256 id, uint256 value, address from, address to) external;
}