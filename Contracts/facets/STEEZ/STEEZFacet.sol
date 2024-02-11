// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts/utils/Address.sol";
import "node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "node_modules/@openzeppelin/contracts/token/ERC2535/IDiamondCut.sol";
import "node_modules/@safe-global/safe-core-sdk";
import "node_modules/@safe-global/safe-contracts/contracts/Safe.sol";
import "node_modules/@safe-global/safe-contracts/contracts/proxies/SafeProxy.sol"; 
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {ISteezFacet} from "../interfaces/ISteezFacet.sol";

// CreatorToken.sol is a facet contract that implements the creator token logic and data for the SteeloToken contract
contract STEEZFacet is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable {
    using LibDiamond for LibDiamond.DiamondStorage;
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

    // EVENTS
    event TokenMinted(uint256 indexed tokenId, address indexed creator, uint256 amount);
    event PreOrderMinted(uint256 indexed tokenId, address indexed investor, uint256 amount);
    event TokenLaunched(uint256 indexed tokenId, uint256 price, uint256 totalSupply);
    event Anniversary(uint256 indexed tokenId);
    event TransactionFeeUpdated(uint256 transactionFee);
    event TokenTransferred(uint256 tokenId, address from, address to, uint256 amount);
    event TokenBurned(uint256 tokenId, address owner, uint256 amount);

    // FUNCTIONS
    function initialize(string memory baseURI, uint256 maxCreatorTokens, uint256 transactionFee) public initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init();
        __Pausable_init();

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.enforceIsContractOwner();
        ds.baseURI = baseURI;
        ds.maxCreatorTokens = maxCreatorTokens;
        ds.transactionFee = transactionFee;
        }

        // Transfer ownership to new owner
        function transferOwnership(address newInvestor, uint256 tokenId) public {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(newInvestor != address(0), "CreatorToken: Transfer to zero address");
            require(newInvestor != ds.creators[tokenId], "CreatorToken: Transfer to current owner");

            address currentInvestor = ds.Investors(tokenId);
            require(currentInvestor == msg.sender || ds.operatorApprovals[currentInvestor][msg.sender], "CreatorToken: Transfer caller is not owner nor approved");

            _transfer(currentInvestor, newInvestor, tokenId);

            ds.Investors[tokenId] = newInvestor;

                // Update balances accordingly in Diamond Storage
                if (_balances[tokenId][currentInvestor] == 0) {
                    _removeInvestor(tokenId, currentInvestor);
                }

                if (_balances[tokenId][newInvestor] > 0) {
                    _addInvestor(tokenId, newInvestor);
                }

            emit OwnershipTransferred(currentInvestor, newInvestor, tokenId); // Ensure this event is declared in your contract
        }

        /**
         * @dev Mints STEEZ tokens to a specified address.
         * @param to Address to mint tokens to.
         * @param tokenId The ID of the STEEZ token to mint.
         * @param amount The number of tokens to mint.
         * @param data Additional data with no specified format.
         * Called by preOrder, launchToken, and expandToken functions
         */
    
        function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) public onlyOwner {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(!ds.tokenExists[tokenId], "CreatorToken: token already exists");
            require(to != address(0), "CreatorToken: Cannot mint to zero address");
            require(ds.totalSupply[tokenId] < ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap reached");
            require(amount > 0, "CreatorToken: Cannot mint zero amount");
            require(tokenId != 0, "CreatorToken: Token ID cannot be 0");
            require(to != ds.creators[tokenId], "CreatorToken: Token creator cannot mint their own tokens");
            require(_currentTokenID.current() < type(uint256).max, "CreatorToken: TokenID overflow");
            require(!ds.tokenExists[tokenId], "Token exists");
            uint256 maxAllowedMint = getMaxAllowedMint(msg.sender, tokenId);

            ds._mint(to, tokenId, amount, data);

            if (_creator[tokenId] == address(0)) {
                _creator[tokenId] = msg.sender;
            }

            ds.transactionCount[tokenId] += amount;
            ds.tokenExists[tokenId] = true;

            // Call separate function from SteezFeesFacet.sol for handling royalties
            payRoyalties(tokenId, amount, to);

            // Update the minting state for annual token increase
            if (_mintedInLastYear[tokenId].add(amount) <= INITIAL_CAP.mul(TRANSACTION_MULTIPLIER)) {
                _mintedInLastYear[tokenId] = _mintedInLastYear[tokenId].add(amount);
                _lastMintTime[tokenId] = block.timestamp;
            }

            emit TokenMinted(tokenId, to, ds.totalSupply[tokenId]);

            // Take a snapshot after minting tokens
            _takeSnapshot();
        }

        // Pre-order function
        function preOrder(uint256 tokenId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(ds.creators[msg.sender], "CreatorToken: Only creators can pre-order tokens.");
            require(ds.totalSupply[tokenId] == 0, "CreatorToken: Pre-order has already been completed.");
            require(amount >= ds.PRE_ORDER_MINIMUM_SOLD, "CreatorToken: Minimum pre-order amount not reached.");

            _mint(msg.sender, tokenId, amount, "");
            ds.totalSupply[tokenId] += amount;

            emit PreOrderMinted(tokenId, msg.sender, amount);        
        }

        // Launch token function
        function launchToken(uint256 tokenId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(ds.creators[msg.sender], "CreatorToken: Only creators can launch tokens.");
            require(ds.totalSupply[tokenId] > 0, "CreatorToken: Pre-order must be completed first.");
            require(ds.totalSupply[tokenId] + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded.");
            require(amount > 0, "CreatorToken: Launch amount must be greater than zero");

            _mint(msg.sender, tokenId, amount, "");
            ds.totalSupply[tokenId] += amount;
            emit TokenLaunched(tokenId, msg.sender, ds.totalSupply[tokenId]);
        }

        // Anniversary Expansion function
        function expandToken(uint256 tokenId, uint256 amount) external payable onlyCreator {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(ds.totalSupply[tokenId] > 0, "CreatorToken: Token does not exist");
            require(ds.totalSupply[tokenId] + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded");

            _mint(msg.sender, tokenId, amount, "");
            ds.totalSupply[tokenId] += amount;
            emit TokenMinted(tokenId, msg.sender, amount);
        }

        function expansionEligible(uint256 tokenId) public view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            return ds.transactionCount[tokenId] >= ds.totalSupply[tokenId] * 2;
        }

        // Function to check annual token increase eligibility and initiate the process
        function checkAndInitiateAnniversary(uint256 tokenId) public {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(ds.creators[tokenId] == msg.sender, "CreatorToken: Only the token creator can initiate an annual token increase.");
            require(block.timestamp >= ds.lastTokenIncrease[tokenId] + ds.ANNIVERSARY_DELAY, "CreatorToken: Annual token increase not yet available.");
            
            uint256 currentSupply = ds.totalSupply[tokenId];
            uint256 newSupply = currentSupply + (currentSupply * ds.ANNUAL_TOKEN_INCREASE_PERCENTAGE / 100);
            ds.totalSupply[tokenId] = newSupply;

            ds.lastTokenIncrease[tokenId] = block.timestamp;

            emit TokenSupplyIncreased(tokenId, newSupply);

            _initiateAnniversary(tokenId);
        }

        // Transfer token balance to specified address
        function transferToken(uint256 tokenId, uint256 amount, address from, address to) external payRoyaltiesOnTransfer(id, amount, from, to) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(to != address(0), "CreatorToken: Transfer to zero address");
            require(from == msg.sender || ds.operatorApprovals[from][msg.sender], "CreatorToken: Transfer caller is not owner nor approved");
            require(to != ds.creators[tokenId], "CreatorToken: Creator cannot buy their own token");
            require(from != to, "CreatorToken: Transfer to self");
            
            address currentInvestor = ownerOf(tokenId);
            address creator = _Creator[tokenId];
            bool isCreator = creator == currentInvestor && !(_balances[tokenId][currentInvestor] > 0);

            // Update balances in diamond storage
            ds.balances[tokenId][to] += amount;
            ds.balances[tokenId][from] -= amount;

            _transfer(currentInvestor, to, tokenId);
            _addRole(to, ROLE_OWNER);

            // Call separate function from SteezFeesFacet.sol for handling royalties
            ds.steezFeesFacet.payRoyalties(tokenId, amount, from, to, data);

            if (_balances[tokenId][currentInvestor] == 0) {
                _removeInvestor(tokenId, currentInvestor);
                _removeRole(from, ROLE_OWNER);
            }

            if (_balances[tokenId][to] > 0) {
                _addInvestor(tokenId, to);
            }

            // Emit TransferWithRoyalty event
            emit TransferWithRoyalty(from, to, tokenId, amount, royaltyAmount); // Ensure this event is declared in your contract
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
}