// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IDiamondCut } from "../../interfaces/IDiamondCut.sol";
import { ISteezFacet } from "../../interfaces/ISteezFacet.sol";
import { SafeProxyFactory } from "../../../lib/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import { SafeL2 } from "../../../lib/safe-contracts/contracts/SafeL2.sol";
import { IPoolManager } from "../../../lib/Uniswap-v4/src/interfaces/IPoolManager.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

// CreatorToken.sol is a facet contract that implements the creator token logic and data for the SteeloToken contract
contract STEEZFacet is SafeL2, ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using LibDiamond for LibDiamond.DiamondStorage;
    using Address for address;
    using Strings for uint256;

    // EVENTS
    event TokenMinted(uint256 indexed tokenId, address indexed creator, uint256 amount);
    event PreOrderMinted(uint256 indexed tokenId, address indexed investor, uint256 amount);
    event auctionConcluded(uint256 tokenId, uint256 _currentPrice, uint256 _totalSupply);
    event LaunchCreated(uint256 indexed tokenId, uint256 price, uint256 _totalSupply);
    event LaunchMinted(uint256 indexed tokenId, uint256 price, uint256 _totalSupply);
    event AnniversaryMinted(uint256 indexed tokenId);
    event SteezTransfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 amount, uint256 royaltyAmount);

    struct Steez {
        uint256 steezId; // mapping(tokenId => mapping(steezId => _investors) 
        address creator; // one creator per tokenId, duplicated through all their steezIds
        bool exists;
        uint256 totalSupply; // starting at 500 and increasing by 500 annually
        uint256 transactionCount;
        uint256 lastMintTime; // to check when to next initiate Anniversary
        uint256 initiateAnniversary;
        uint256 currentPrice; // determined by pre-order auction price, then via Supply x Demand AMM model
        string baseURI;
        uint256 auctionStartTime; // 250 out of the 500 initially minted tokens for pre-order
        uint256 auctionSlotsSecured; // increments price by £10 every 250 token auctions at new price 
        bool auctionConcluded;
        mapping(address => uint256) investors; // capturing all investors
        mapping(address => uint256) balances; // capturing all balances
    }

    uint256 oneYearInSeconds = 365 days;
    address private uniswapRouterAddress;
    uint256 private _lastTokenId;

    modifier canCreateToken(address creator) {require(!steezes[tokenId].exists, "CreatorToken: Creator has already created a token.");
        _;
    }

    modifier withinAuctionPeriod() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(steezes[tokenId].auctionStartTime != 0, "Auction has not started yet");
        require(block.timestamp < steezes[tokenId].auctionStartTime + ds.AUCTION_DURATION, "Auction duration has ended");
        _;
    }

    // FUNCTIONS
    function initialize(string memory baseURI) public initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        baseURI = _baseURI;
        }

        function transferTokenOwnership(address newInvestor, uint256 tokenId, uint256 steezId) public {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(newInvestor != address(0), "CreatorToken: Transfer to zero address");
            require(newInvestor != steezes[steezId].investors, "CreatorToken: Transfer to current owner");

            address currentInvestor = steezes[steezId].investors;
            require(currentInvestor == msg.sender || ds.operatorApprovals[currentInvestor][msg.sender], "CreatorToken: Transfer caller is not owner nor approved");

            _transfer(currentInvestor, newInvestor, tokenId);

            steezes[steezId].investors = newInvestor;

            // Update balances accordingly in Diamond Storage
            if (steezes[steezId].balances[currentInvestor] == 0) {
                _removeInvestor(steezId, currentInvestor);
            }

            if (steezes[steezId].balances[newInvestor] > 0) {
                _addInvestor(tokenId, newInvestor);
            }

            emit OwnershipTransferred(currentInvestor, newInvestor, tokenId); // Ensure this event is declared in your contract
        }

        /**
         * @dev Mints STEEZ tokens to a specified address.
         * @param to Address to mint tokens to.
         * @param data Additional data with no specified format.
         * Called by preOrder, launchToken, and expandToken functions
         */
        function createSteez(address to, bytes memory data) public onlyOwner nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            _lastTokenId++;
            uint256 tokenId = _lastTokenId;
            uint256 amount = ds.INITIAL_SUPPLY;
            require(canCreateToken(msg.sender), "CreatorToken: Creator has already created a token.");
            require(tokenId != 0, "CreatorToken: Token ID cannot be 0");
            require(tokenId.current() < type(uint256).max, "CreatorToken: TokenID overflow");
            require(to != address(0), "CreatorToken: Cannot mint to zero address");
            require(!steezes[tokenId].tokenExists, "CreatorToken: token already exists");
            uint256 maxAllowedMint = getMaxAllowedMint(msg.sender, tokenId);

            _mint(to, tokenId, steezId, amount, data);

            if (steezes[tokenId].creator == address(0)) {
                steezes[tokenId].creator = msg.sender;
            }

            steezes[tokenId].exists = true;

            // Call separate function from SteezFeesFacet.sol for handling royalties
            steezFeesFacet.payRoyalties(tokenId, amount, to, data);

            // Update the minting state for annual token increase
            if (steezes[tokenId].lastMintTime == 0 || (steezes[tokenId].lastMintTime + oneYearInSeconds) <= block.timestamp) {
                steezes[tokenId].lastMintTime = block.timestamp;
            }

            emit TokenCreated(tokenId, to, _totalSupply[tokenId]);

            // Take a snapshot after minting tokens
            ds.snapshotFacet.takeSnapshot();
        }

        // Pre-order function
        function preOrder(uint256 tokenId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(creator[msg.sender], "CreatorToken: Only creators can initiate pre-orders.");
            require(!_auctionConcluded, "CreatorToken: Auction has concluded.");
        
            // Initialize auction start time if this is the first call
            if (steezes[tokenId].auctionStartTime == 0) {
                steezes[tokenId].auctionStartTime = block.timestamp;
            }

            require(block.timestamp < auctionStartTime + ds.AUCTION_DURATION, "CreatorToken: Auction duration has ended.");

            // Calculate required payment based on currentPrice and amount
            uint256 requiredPayment = steezes[tokenId].currentPrice * amount;
            require(msg.value >= requiredPayment, "CreatorToken: Insufficient payment.");

            // Update auction state
            steezes[tokenId].auctionSlotsSecured += amount;
            if (steezes[tokenId].auctionSlotsSecured >= ds.TOKEN_BATCH_SIZE) {
                // Increment price for next batch and reset token count
                steezes[tokenId].currentPrice += ds.PRICE_INCREMENT;
                steezes[tokenId].auctionSlotsSecured = steezes[tokenId].auctionSlotsSecured % ds.TOKEN_BATCH_SIZE; // Handle any excess tokens in this payment
            }

            // After 24 hours, conclude auction and release additional tokens at initial price
            if (block.timestamp >= steezes[tokenId].auctionStartTime + ds.AUCTION_DURATION) {
                // Additional logic to mint and list ds.EXTRA_TOKENS_AFTER_AUCTION at INITIAL_PRICE
                // Consider a separate function to handle this if the logic is complex
            }

            // Refund excess payment
            uint256 excessPayment = msg.value - requiredPayment;
            if (excessPayment > 0) {
                payable(msg.sender).transfer(excessPayment);
            }
    
            // Mint tokens for the creator
            _mint(msg.sender, tokenId, steezId, amount, "");
            steezes[tokenId].totalSupply[tokenId] += amount;

            emit PreOrderMinted(tokenId, msg.sender, amount);
            BazaarFacet.addLiquidityForToken(tokenId, amount, msg.value);
        }

        function concludeAuction() external {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(block.timestamp >= steezes[tokenId].auctionStartTime + ds.AUCTION_DURATION, "Auction is still active");
            require(!steezes[tokenId].auctionConcluded, "Auction has already been concluded");
            
            steezes[tokenId].auctionConcluded = true;

            // Mint EXTRA_TOKENS_AFTER_AUCTION
            mint(EXTRA_TOKENS_AFTER_AUCTION);
            
            // List the minted tokens at INITIAL_PRICE
            list(INITIAL_PRICE);

            emit auctionConcluded(tokenId, steezes[tokenId].currentPrice, steezes[tokenId].totalSupply);
        }

        // Launch token function
        function launchToken(uint256 tokenId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(creator[msg.sender], "CreatorToken: Only creators can launch tokens.");
            require(steezes[tokenId].totalSupply > 0, "CreatorToken: Pre-order must be completed first.");
            require(steezes[tokenId].totalSupply + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded.");
            require(amount > 0, "CreatorToken: Launch amount must be greater than zero");

            _mint(msg.sender, tokenId, steezId, amount, "");
            steezes[tokenId].totalSupply[tokenId] += amount;
            emit LaunchMinted(tokenId, msg.sender, steezes[tokenId].totalSupply);
        }

        // Anniversary Expansion function
        function expandToken(uint256 tokenId, uint256 amount) external payable onlyOwner nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(steezes[tokenId].totalSupply > 0, "CreatorToken: Token does not exist");
            require(steezes[tokenId].totalSupply + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded");

            // Add additional liquidity to Uniswap pool
            address tokenAddress = _convertTokenIdToAddress(tokenId);
            uint256 additionalTokenAmount = amount;
            uint256 additionalSteeloAmount = msg.value;
            
            bazaarFacet.ds._addLiquidity(uniswapRouterAddress, tokenAddress, additionalSteeloAmount, additionalTokenAmount);
            _mint(msg.sender, tokenId, steezId, amount, "");
            steezes[tokenId].totalSupply[tokenId] += amount;
           
            emit TokenMinted(tokenId, msg.sender, amount);
        }

        function expansionEligible(uint256 tokenId) public view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            return steezes[tokenId].transactionCount >= steezes[tokenId].totalSupply * 2;
        }

        // Function to check annual token increase eligibility and initiate the process
        function initiateAnniversary(uint256 tokenId) public {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(steezes[tokenId].creator == msg.sender, "CreatorToken: Only the token creator can initiate an annual token increase.");
            require(block.timestamp >= steezes[tokenId].lastMintTime + ds.ANNIVERSARY_DELAY, "CreatorToken: Annual token increase not yet available.");
            
            uint256 currentSupply = steezes[tokenId].totalSupply;
            uint256 newSupply = currentSupply + (currentSupply * ds.ANNUAL_TOKEN_INCREASE_PERCENTAGE / 100);
            steezes[tokenId].totalSupply = newSupply;

            steezes[tokenId].lastMintTime = block.timestamp;
            _initiateAnniversary(tokenId);
            emit AnniversaryMinted(tokenId);
        }

        // Transfer token balance to specified address
        function transferToken(uint256 tokenId, uint256 amount, address from, address to) external nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(to != address(0), "CreatorToken: Transfer to zero address");
            require(from == msg.sender || ds.operatorApprovals[from][msg.sender], "CreatorToken: Transfer caller is not owner nor approved");
            require(to != steezes[tokenId].creator, "CreatorToken: Creator cannot buy their own token");
            require(from != to, "CreatorToken: Transfer to self");
            require(steezes[tokenId].balances[from] >= amount, "CreatorToken: Transfer amount exceeds balance");

            address creator = steezes[tokenId].creator;
            bool isCreator = creator == from && !(steezes[tokenId].balances[from] > 0);

            // Update balances in diamond storage
            steezes[tokenId].balances[to] += amount;
            steezes[tokenId].balances[from] -= amount;

            _transfer(currentInvestor, to, tokenId);
            _addRole(to, ROLE_OWNER);

            // Call separate function from SteezFeesFacet.sol for handling royalties
            ds.steezFeesFacet.payRoyalties(tokenId, amount, from, to, data);

            if (steezes[tokenId].balances[currentInvestor] == 0) {
                _removeInvestor(tokenId, currentInvestor);
                _removeRole(from, ROLE_OWNER);
            }

            if (steezes[tokenId].balances[to] > 0) {
                _addInvestor(tokenId, to);
            }

            // Emit SteezTransfer event
            emit SteezTransfer(from, to, tokenId, amount, royaltyAmount); // Ensure this event is declared in your contract
        }

        // Transfers multiple tokens of different types and amounts to different addresses, while checking for the recipient's ability to receive ERC1155
        function safeBatchTransfer(address[] memory to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) public {
            require(to.length == tokenIds.length && tokenIds.length == amounts.length, "CreatorToken: Arrays length must match");

            for (uint256 i = 0; i < to.length; i++) {
                safeTransferFrom(msg.sender, to[i], tokenIds[i], amounts[i], data);
            }
        }

        function _mint(address to, uint256 tokenId, uint256 steezId, uint256 amount, bytes memory data) internal {
            for (uint256 i = 0; i < amount; i++) {
                _mint(to, steezes[tokenId].steezId + i);
                steezes[tokenId].steezId + i = to;
            }
        }

        function _convertTokenIdToAddress(uint256 tokenId) internal view returns (address) {
            require(_exists(tokenId), "ERC721: operator query for nonexistent token");
            return steezes[tokenId].investors;
        }

        function _transfer(address from, address to, uint256 steezId) internal virtual {
            require(ownerOf(steezId) == from, "ERC721: transfer of token that is not own");
            require(to != address(0), "ERC721: transfer to the zero address");

            _beforeTokenTransfer(from, to, steezId);

            // Clear approvals from the previous owner
            _approve(address(0), steezId);

            steezes[steezId].balances[from] -= 1;
            steezes[steezId].balances[to] += 1;
            steezes[steezId].investors = to;

            emit Transfer(from, to, steezId);
        }

        function _removeInvestor(uint256 tokenId, address currentInvestor) private {
            require(steezes[tokenId].investors == currentInvestor, "This address does not own the token");
            steezes[tokenId].investors = address(0);
        }

        function _addInvestor(uint256 tokenId, address newInvestor) private {
            require(steezes[tokenId].investors == address(0), "This token is already owned");
            steezes[tokenId].investors = newInvestor;
        }

        function _addRole(address to, bytes32 role) internal {
            _setupRole(role, to);
        }

        function getMaxAllowedMint(address sender, uint256 tokenId) private view returns (uint256) {
            // This is a placeholder. Replace with your own logic.
            return 10;
        }
}