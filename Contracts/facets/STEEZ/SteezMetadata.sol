// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./libraries/LibDiamond.sol";

contract SteezMetadataFacet {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;
    }

        function totalSupply(uint256 tokenId) public view returns (uint256) {
            return _totalSupply[tokenId];
        }

        function tokenCreator(uint256 tokenId) public view returns (address) {
            return _creator[tokenId];
        }

        function royalty(uint256 tokenId) public view returns (uint256) {
            return _royalty[tokenId];
        }

        function transactionCount(uint256 tokenId) public view returns (uint256) {
            return _transactionCount[tokenId];
        }

        function mintedInLastYear(uint256 tokenId) public view returns (uint256) {
            return _mintedInLastYear[tokenId];
        }

        function lastMintTime(uint256 tokenId) public view returns (uint256) {
            return _lastMintTime[tokenId];
        }