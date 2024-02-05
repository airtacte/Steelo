// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./libraries/LibDiamond.sol";

contract SteezManagementFacet {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;
    }

        // Update transaction fee function
        function updateTransactionFee(uint256 transactionFee) external onlyOwner {
            require(transactionFee <= 100, "CreatorToken: Transaction fee cannot exceed 100%");
            _transactionFee = transactionFee;

            emit TransactionFeeUpdated(transactionFee);
        }

        // Transfers multiple tokens of different types and amounts to different addresses, while checking for the recipient's ability to receive ERC1155
        function safeBatchTransfer(address[] memory to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) public {
            require(to.length == tokenIds.length && tokenIds.length == amounts.length, "CreatorToken: Arrays length must match");

            for (uint256 i = 0; i < to.length; i++) {
                safeTransfer(to[i], tokenIds[i], amounts[i], data);
            }
        }

        // Transfers multiple tokens of different types and amounts to different addresses, but requires the tokens to be previously approved for safe transfer
        function safeBatchTransferFrom(address from, address[] memory to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) public {
            require(to.length == tokenIds.length && tokenIds.length == amounts.length, "CreatorToken: Arrays length must match");

            for (uint256 i = 0; i < to.length; i++) {
                safeTransferFrom(from, to[i], tokenIds[i], amounts[i], data);
            }
        }

        // Custom transfer function for royalty distribution
       function transfer(address from, address to, uint256 tokenId) public {
            require(exists(tokenId), "CreatorToken: Token does not exist.");
            require(isApprovedOrOwner(msg.sender, tokenId), "CreatorToken: Caller is not owner nor approved.");
            require(from != address(0), "CreatorToken: Transfer from zero address.");
            require(to != address(0), "CreatorToken: Transfer to zero address.");
            require(from != to, "CreatorToken: Transfer to self not allowed");
            require(to != address(this), "CreatorToken: Transfer to contract address.");
            require(balance > 0, "CreatorToken: Insufficient balance.");

            _royalties.transfer(from, to, tokenId, amount);
            _royalties.transferWithRoyalty(from, to, tokenId, amount);

            _safeTransferFrom(from, to, tokenId, amount, "");

            uint256 balance = balanceOf(from, tokenId);

            emit TokenTransferred(tokenId, from, to, amount);
        }

        // Check if the given token exists and returns an array of unique addresses that hold the token
        function getHolders(uint256 tokenId) public view returns (address[] memory) {
            require(_exists(tokenId), "CreatorToken: Token does not exist");
            
            address[] memory holders = new address[](_tokenHolders[tokenId].length());
            for (uint256 i = 0; i < _tokenHolders[tokenId].length(); i++) {
                holders[i] = _tokenHolders[tokenId].at(i);
            }
            
            return holders;
        }

        // Override uri function from ERC1155Upgradeable.sol
        function uri(uint256 tokenId) public view virtual override returns (string memory) {
            return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId)));
            return _royalties.getTokenURI(tokenId);
        }

        // Pause contract
        function pause() public onlyOwner {
            _pause();
        }

        // Unpause contract
        function unpause() public onlyOwner {
            _unpause();
        }

        // Withdraw transaction fee
        function withdraw() public onlyOwner {
            payable(owner()).transfer(address(this).balance);
        }

        // Fallback function
        receive() external payable {}

