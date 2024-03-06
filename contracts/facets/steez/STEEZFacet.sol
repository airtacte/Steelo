// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IDiamondCut } from "../../interfaces/IDiamondCut.sol";
import { BazaarFacet } from "../features/BazaarFacet.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { SteezFeesFacet } from "./SteezFeesFacet.sol";
import { SnapshotFacet } from "../app/SnapshotFacet.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// CreatorToken.sol is a facet contract that implements the creator token logic and data for the SteeloToken contract
contract STEEZFacet is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    address steezFacetAddress;
    bytes32 public constant ROLE_OPERATOR = keccak256("ROLE_OPERATOR");
    bytes32 public constant ROLE_OWNER = keccak256("ROLE_OWNER");
    using LibDiamond for LibDiamond.DiamondStorage;
    using Address for address;
    using Strings for uint256;

    // EVENTS
    event NewSteez(address indexed creatorId, bytes memory data);
    event TokenMinted(uint256 indexed creatorId, address indexed investors, uint256 amount);
    event PreOrderMinted(uint256 indexed creatorId, address indexed investors, uint256 amount);
    event auctionConcluded(uint256 creatorId, uint256 currentPrice, uint256 totalSupply);
    event LaunchCreated(uint256 indexed creatorId, uint256 currentPrice, uint256 totalSupply);
    event LaunchMinted(uint256 indexed creatorId, uint256 currentPrice, address indexed investors, uint256 amount);
    event AnniversaryMinted(uint256 indexed creatorId, uint256 totalSupply, uint256 currentPrice, address indexed investors, uint256 amount);
    event SteezTransfer(address indexed from, address indexed to, uint256 indexed steezId, uint256 amount, uint256 royaltyAmount);

    modifier canCreateToken(address creator) {
        require(!LibDiamond.diamondStorage().steez[creator].creatorExists, "CreatorToken: Creator has already created a token.");
        _;
    }

    modifier withinAuctionPeriod(uint256 creatorId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.steez[creatorId].auctionStartTime != 0, "Auction has not started yet");
        require(block.timestamp < ds.steez[creatorId].auctionStartTime + ds.constants.AUCTION_DURATION, "Auction duration has ended");
        _;
    }

    // FUNCTIONS
    function initialize(string memory _baseURI) public initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        steezFacetAddress = ds.steezFacetAddress;
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        baseURI = _baseURI;
        }

        /**
         * @dev Create STEEZ token for specific creator, mint handled seperately after pre-order.
         * @param data Additional data with no specified format.
         */
        function createSteez(bytes memory data) public onlyOwner nonReentrant canCreateToken(msg.sender) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            SnapshotFacet snapshot = SnapshotFacet(ds.snapshotFacetAddress);
            require(msg.sender != address(0), "CreatorToken: Cannot mint to zero address");
 
            // Incrementing for unique, ascending IDs
            uint256 creatorId = ds._lastCreatorId++;
            uint256 profileId = ds._lastProfileId++;
            uint256 steezId = ds._lastSteezId++;
            
            require(creatorId < type(uint256).max, "CreatorToken: creator overflow");
            require(!ds.steez[creatorId].creatorExists, "CreatorToken: token already exists");

            ds.creators[profileId] = LibDiamond.Creator({
                creatorId: creatorId,
                profileId: profileId,
                profileAddress: msg.sender
            });
            
            ds.steez[creatorId] = LibDiamond.Steez({
                creatorId: creatorId,
                steezId: steezId,
                creatorExists: true,
                totalSupply: 0,
                transactionCount: 0,
                lastMintTime: block.timestamp,
                anniversaryDate: block.timestamp + ds.constants.oneYear,
                currentPrice: 30 ether,
                baseURI: ds.baseURI,
                auctionStartTime: block.timestamp + ds.constants.oneWeek,
                auctionSlotsSecured: 0,
                auctionConcluded: false
                // Note: All structs part of Steez that are mappings are not initialized here
            });

            // Update the minting state for annual token increase
            if (ds.steez[creatorId].lastMintTime == 0 || (ds.steez[creatorId].lastMintTime + ds.constants.oneYear) <= block.timestamp) {
                ds.steez[creatorId].lastMintTime = block.timestamp;
            }

            emit NewSteez(creatorId, data);
            snapshot.takeSnapshot();
        }

        // Pre-order function
        function preOrder(uint256 creatorId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarFacetAddress);
            require(ds.steez[creatorId].creatorId == creatorId, "CreatorToken: Only creators can initiate pre-orders.");
            require(!ds.steez[creatorId].auctionConcluded, "CreatorToken: Auction has concluded.");
            ds.steez[creatorId].totalSupply = ds.constants.PRE_ORDER_SUPPLY;

            // Initialize auction start time if this is the first call
            if (ds.steez[creatorId].auctionStartTime == 0) {
                ds.steez[creatorId].auctionStartTime = block.timestamp;
            }

            // AUCTION START PRICE = ds.constants.INITIAL_PRICE - to setup

            require(block.timestamp < ds.steez[creatorId].auctionStartTime + ds.constants.AUCTION_DURATION, "CreatorToken: Auction duration has ended.");

            // Calculate required payment based on currentPrice and amount
            uint256 requiredPayment = ds.steez[creatorId].currentPrice * amount;
            require(msg.value >= requiredPayment, "CreatorToken: Insufficient payment.");

            // Update auction state
            ds.steez[creatorId].auctionSlotsSecured += amount;
            if (ds.steez[creatorId].auctionSlotsSecured >= ds.constants.PRE_ORDER_SUPPLY) {
                // Increment price for next batch and reset token count
                ds.steez[creatorId].currentPrice += ds.constants.PRICE_INCREMENT;
                ds.steez[creatorId].auctionSlotsSecured = ds.steez[creatorId].auctionSlotsSecured % ds.constants.PRE_ORDER_SUPPLY; // Handle any excess tokens in this payment
            }

            // After 24 hours, conclude auction and proceed with mints and refunds
            if (block.timestamp >= ds.steez[creatorId].auctionStartTime + ds.constants.AUCTION_DURATION) {
                ds.steez[creatorId].auctionConcluded = true;
            }

            // Refund excess payment
            uint256 excessPayment = msg.value - requiredPayment;
            if (excessPayment > 0) {
                payable(msg.sender).transfer(excessPayment);
            }
    
            // Mint tokens for the creator
            this.mint(to, creatorId, amount, data);
            steezFees.payRoyalties(from, to, creatorId, amount, data);

            emit PreOrderMinted(ds.steez[creatorId].creatorId, msg.sender, amount);
            bazaar.addLiquidityForToken(ds.steez[creatorId].creatorId, amount, msg.value);
            launch(ds.steez[creatorId].creatorId, amount);
        }

        // Launch function
        function launch(uint256 creatorId, uint256 amount) internal {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarFacetAddress);
            require(block.timestamp >= ds.steez[creatorId].auctionStartTime + ds.constants.AUCTION_DURATION, "Auction is still active");
            require(!ds.steez[creatorId].auctionConcluded, "Auction has already been concluded");
            
            ds.steez[creatorId].auctionConcluded = true;

            // Mint EXTRA_TOKENS_AFTER_AUCTION
            super._mint(to, creatorId, ds.constants.EXTRA_TOKENS_AFTER_AUCTION, data);
            steezFees.payRoyalties(from, to, creatorId, amount, data);

            // List the minted tokens at INITIAL_PRICE
            bazaar.listCreatorToken(creatorId, ds.steez[creatorId].currentPrice);

            emit auctionConcluded(creatorId, ds.steez[creatorId].currentPrice, ds.steez[creatorId].totalSupply);

            // Launch token
            require(ds.steez[creatorId].totalSupply > 0, "CreatorToken: Pre-order must be completed first.");
            require(ds.steez[creatorId].totalSupply + amount <= ds.constants.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded.");
            require(amount > 0, "CreatorToken: Launch amount must be greater than zero");

            // Mint tokens for the launch
            ds.steez[creatorId].totalSupply = ds.steez[creatorId].totalSupply + ds.constants.LAUNCH_SUPPLY;
            this.mint(msg.sender, ds.steez[creatorId].creatorId, amount, data);
            ds.steez[creatorId].totalSupply += amount;
            emit LaunchMinted(ds.steez[creatorId].creatorId, msg.sender, ds.steez[creatorId].totalSupply);
        }

        // Anniversary Expansion function
        function anniversary(uint256 creatorId, uint256 amount) external payable onlyOwner nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarFacetAddress);
            require(ds.steez[creatorId].totalSupply > 0, "CreatorToken: Token does not exist");
            require(ds.steez[creatorId].totalSupply + amount <= ds.constants.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded");
            require(ds.steez[creatorId].transactionCount >= ds.steez[creatorId].totalSupply * 2, "CreatorToken: Expansion not eligible");
            require(ds.steez[creatorId].creatorId == creatorId, "CreatorToken: Only the token creator can initiate an annual token increase.");
            require(block.timestamp >= ds.steez[creatorId].lastMintTime + ds.constants.ANNIVERSARY_DELAY, "CreatorToken: Annual token increase not yet available.");

            bazaar.addLiquidity(creatorId, ds.constants.EXPANSION_SUPPLY, ds.steez[creatorId].currentPrice);

            uint256 currentSupply = ds.steez[creatorId].totalSupply;
            uint256 newSupply = currentSupply + (currentSupply * ds.constants.ANNUAL_TOKEN_INCREASE_PERCENTAGE / 100);
            ds.steez[creatorId].totalSupply = newSupply;
            ds.steez[creatorId].lastMintTime = block.timestamp;
            
            super._mint(to, creatorId, ds.constants.EXPANSION_SUPPLY, data);
            steezFees.payRoyalties(from, to, creatorId, amount, data);

            emit AnniversaryMinted(ds.steez[creatorId].creatorId);
        }

        // Transfer token balance and ownership to specified address
        function transferSteez(uint256 creatorId, uint256 steezId, uint256 amount, address from, address to) external nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            AccessControlFacet accessControl = AccessControlFacet(ds.accessControlFacetAddress);
            SteezFeesFacet steezFees = SteezFeesFacet(ds.steezFeesFacetAddress);
            require(to != address(0), "CreatorToken: Transfer to zero address");
            require(from == msg.sender || accessControl.hasRole(ROLE_OPERATOR, msg.sender), "CreatorToken: Transfer caller is not owner nor approved");
            require(to != creatorId, "CreatorToken: Creator cannot buy their own token");
            require(from != to, "CreatorToken: Transfer to self");

            // Check if sender is an investor and has enough balance
            bool senderIsInvestor = false;
            for (uint256 i = 0; i < ds.steez[creatorId].investors.length; i++) {
                if (ds.steez[creatorId].investors[i].investorAddress == from) {
                    require(ds.steez[creatorId].investors[i].balance >= amount, "CreatorToken: Transfer amount exceeds balance");
                    senderIsInvestor = true;
                    break;
                }
            }
            require(senderIsInvestor, "CreatorToken: Sender is not an investor");

            address creator = creatorId;
            bool isCreator = creator == from && !(ds.steez[creatorId].balances[from] > 0);

            // Update balances in diamond storage
            ds.steez[creatorId].balances[from] -= amount;
            ds.steez[creatorId].balances[to] += amount;

            // Transfer ownership
            ds.steez[creatorId].investors = to;

            _transfer(from, to, ds.steez[creatorId].creatorId);
            accessControl.grantRole(ROLE_OWNER, to);
            steezFees.payRoyalties(from, to, creatorId, amount, data);

            if (ds.steez[creatorId].balances[from] == 0) {
                _removeInvestor(ds.steez[creatorId].creatorId, from);
                accessControl.revokeRole(ROLE_OWNER, from);
            }

            if (ds.steez[creatorId].balances[to] > 0) {
                _addInvestor(ds.steez[creatorId].creatorId, to, amount);
            }

            // Emit SteezTransfer event
            emit SteezTransfer(from, to, ds.steez[creatorId].creatorId, amount);
        }

        function safeBatchTransfer(address[] memory to, uint256[] memory creatorIds, uint256[] memory amounts, bytes memory data) public {
            require(to.length == creatorIds.length && creatorIds.length == amounts.length, "CreatorToken: Arrays length must match");

            for (uint256 i = 0; i < to.length; i++) {
                safeTransferFrom(msg.sender, to[i], creatorIds[i], amounts[i], data);
            }
        }

        function _mint(address to, uint256 creatorId, uint256 amount, bytes memory data) internal {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            SteezFeesFacet steezFees = SteezFeesFacet(ds.steezFeesFacetAddress);
            super._mint(to, creatorId, amount, data); // Corrected _mint call to match ERC1155 signature
            steezFees.payRoyalties(from, to, creatorId, amount, data); // Assuming such a method exists in SteezFeesFacet
        }

        function _transfer(address from, address to, uint256 steezId) internal virtual {
            require(to != address(0), "ERC721: transfer to the zero address");

            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            LibDiamond.Steez storage steez = ds.steez[steezId];
            bool isInvestor = false;
            uint i;
            for (i = 0; i < steez.investors.length; i++) {
                if (steez.investors[i].investorAddress == from) {
                    isInvestor = true;
                    break;
                }
            }
            require(isInvestor, "ERC721: transfer of token that is not own");

            // Decrease the balance of the sender
            steez.investors[i].balance -= 1;

            // If the sender's balance is 0, remove them from the investor list
            if (steez.investors[i].balance == 0) {
                steez.investors[i] = steez.investors[steez.investors.length - 1];
                steez.investors.pop();
            }

            // Increase the balance of the receiver
            bool isReceiverInvestor = false;
            for (i = 0; i < steez.investors.length; i++) {
                if (steez.investors[i].investorAddress == to) {
                    steez.investors[i].balance += 1;
                    isReceiverInvestor = true;
                    break;
                }
            }

            // If the receiver is not already an investor, add them to the list
            if (!isReceiverInvestor) {
                steez.investors.push(LibDiamond.Investor({
                    investorAddress: to,
                    balance: 1
                }));
            }

            emit SteezTransfer(from, to, steezId, amount);
        }

        function _removeInvestor(uint256 creatorId, address currentInvestor) internal {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

            // Find the investor in the array
            uint256 investorIndex = uint256(-1);
            for (uint i = 0; i < ds.steez[creatorId].investors.length; i++) {
                if (ds.steez[creatorId].investors[i].investorAddress == currentInvestor) {
                    investorIndex = i;
                    break;
                }
            }

            // Only remove the investor if they exist in the array and their balance is 0
            if (investorIndex != uint256(-1) && ds.steez[creatorId].investors[investorIndex].balance == 0) {
                // Remove the investor from the array
                uint256 lastIndex = ds.steez[creatorId].investors.length - 1;
                ds.steez[creatorId].investors[investorIndex] = ds.steez[creatorId].investors[lastIndex];
                ds.steez[creatorId].investors.pop();
            }
        }

        function _addInvestor(uint256 creatorId, address investorAddress, uint256 amount) internal {
            DiamondStorage storage ds = diamondStorage();
            // Check if investor already exists
            bool investorExists = false;
            for (uint256 i = 0; i < ds.steez[creatorId].investors.length; i++) {
                if (ds.steez[creatorId].investors[i].investorAddress == investorAddress) {
                    investorExists = true;
                    break;
                }
            }
            require(!investorExists, "Investor already exists");

            // Increment last profile ID first before assigning it to ensure uniqueness
            ds._lastProfileId++;
            
            LibDiamond.Investor memory newInvestor = LibDiamond.Investor({
                profileId: ds._lastProfileId,
                investorAddress: investorAddress,
                balance: amount // initiate balance with purchased amount
            });

            ds.steez[creatorId].investors.push(newInvestor);
        }

        function _findInvestorIndex(uint256 creatorId, address investorAddress) private view returns (uint256) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            for (uint256 i = 0; i < ds.steez[creatorId].investors.length; i++) {
                if (ds.steez[creatorId].investors[i].investorAddress == investorAddress) {
                    return i;
                }
            }
            return uint256(-1);
        }
}