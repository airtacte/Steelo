// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IDiamondCut } from "../../interfaces/IDiamondCut.sol";
import { ISteezFacet } from "../../interfaces/ISteezFacet.sol";
import { BazaarFacet } from "../features/BazaarFacet.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { SteezFeesFacet } from "./SteezFeesFacet.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// CreatorToken.sol is a facet contract that implements the creator token logic and data for the SteeloToken contract
contract STEEZFacet is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    bytes32 public constant ROLE_OPERATOR = keccak256("ROLE_OPERATOR");
    bytes32 public constant ROLE_OWNER = keccak256("ROLE_OWNER");
    using LibDiamond for LibDiamond.DiamondStorage;
    using Address for address;
    using Strings for uint256;

    // EVENTS
    event NewCreatorSteez(address indexed creatorId);
    event TokenMinted(uint256 indexed creatorId, address indexed investors, uint256 amount);
    event PreOrderMinted(uint256 indexed creatorId, address indexed investors, uint256 amount);
    event auctionConcluded(uint256 creatorId, uint256 currentPrice, uint256 totalSupply);
    event LaunchCreated(uint256 indexed creatorId, uint256 currentPrice, uint256 totalSupply);
    event LaunchMinted(uint256 indexed creatorId, uint256 currentPrice, address indexed investors, uint256 amount);
    event AnniversaryMinted(uint256 indexed creatorId, uint256 totalSupply, uint256 currentPrice, address indexed investors, uint256 amount);
    event SteezTransfer(address indexed from, address indexed to, uint256 indexed steezId, uint256 amount, uint256 royaltyAmount);

    struct Investor {
        uint256 profileId; // ID of the investor's user profile
        uint256 balance; // quantity of Steez owned by the investor
    }

    struct Royalty {
        uint256 totalRoyalties; // Total royalties accrued for this Steez
        mapping(address => uint256) royaltyAmounts; // Mapping from investor address to the total amount of royalties received
        mapping(address => uint256[]) royaltyPayments; // Mapping from investor address to array of individual royalty payments received
    }
    
    struct Steez {
        address creator; // one creator holds 500+ steezIds
        uint256 steezId; // mapping(creatorId => mapping(steezId => investors) 
        uint256 totalSupply; // starting at 500 and increasing by 500 annually
        uint256 transactionCount;
        uint256 lastMintTime; // to check when to next initiate Anniversary
        uint256 anniversaryDate; // to check when to next initiate Anniversary
        uint256 currentPrice; // determined by pre-order auction price, then via Supply x Demand AMM model
        uint256 auctionStartTime; // 250 out of the 500 initially minted tokens for pre-order
        uint256 auctionSlotsSecured; // increments price by £10 every 250 token auctions at new price 
        string baseURI; // base URI for token metadata
        bool creatorExists; // only one steez per creator
        bool auctionConcluded; // 24hr auction after 1 week of pre-order
        Investor[] investors; // investors array
        Royalty royalties; // Integrated Royalty struct for managing royalties
    }

    mapping(address => Steez) public creatorSteez;
    uint256 oneYearInSeconds = 365 days;
    uint256 oneWeekInSeconds = 7 days;
    uint256 private _lastCreatorId;
    string public baseURI;

    modifier canCreateToken(address creator) {require(!Steez[creator].creatorExists, "CreatorToken: Creator has already created a token.");
        _;
    }

    modifier withinAuctionPeriod() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(Steez[creatorSteez].auctionStartTime != 0, "Auction has not started yet");
        require(block.timestamp < Steez[creatorSteez].auctionStartTime + ds.AUCTION_DURATION, "Auction duration has ended");
        _;
    }

    // FUNCTIONS
    function initialize(string memory _baseURI) public initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        baseURI = _baseURI;
        }

        /**
         * @dev Mints STEEZ tokens to a specified address.
         * @param to Address to mint tokens to.
         * @param data Additional data with no specified format.
         * Called by preOrder, launchToken, and expandToken functions
         */
        function createSteez(address to, bytes memory data) public onlyOwner nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(canCreateToken(msg.sender), "CreatorToken: Creator has already created a token.");
            require(Steez[creatorSteez].creator != 0, "CreatorToken: Token ID cannot be 0");
            require(Steez[creatorSteez].creator.current() < type(uint256).max, "CreatorToken: creator overflow");
            require(to != address(0), "CreatorToken: Cannot mint to zero address");
            require(!Steez[creatorSteez].creatorExists, "CreatorToken: token already exists");

            Steez memory steez = Steez({
                creator: msg.sender, // = profileId
                steezId: _lastCreatorId++, // increment _lastCreatorId for each new Steez
                creatorExists: true,
                totalSupply: 0, // 250 post-auction, 250 post-launch, 500 post-anniversaries
                transactionCount: 0,
                lastMintTime: block.timestamp, // set to current time
                anniversaryDate: block.timestamp + oneYearInSeconds, // set to one year from now
                currentPrice: 30 ether, // £30 initial price
                baseURI: baseURI,
                auctionStartTime: block.timestamp + oneWeekInSeconds, // set to one week from now
                auctionSlotsSecured: 0, // up to 250 slots secured, reset each incremental round
                auctionConcluded: false, // 24hr after auctionStartTime (8 days after mint)
                investors: new Investor[](0), // Initialize an empty array of Investor structs
                royalties: Royalty({totalRoyalties: 0, unclaimedRoyalties: 0}) // Initialize Royalty
            });

            Investor memory newInvestor = Investor({
                investorAddress: msg.sender,
                balance: 0 // initial balance
            });

            Investor memory investor = steez.investors[i]; // Get investor
            uint256[] memory royalties = steez.royalties.investorRoyalties[investor.investorAddress]; // Get investor's royalties

            // Add entries to the investors and balances mappings
            investors[msg.sender] = 0; // example values
            balances[msg.sender] = 0; // example values
            creatorSteez[msg.sender] = steez; // stores steez object in creatorSteez mapping
            
            uint256 creatorId = _lastCreatorId;
            _mint(to, creatorId, creatorSteez[creatorId].steezId, data);

            // Update the minting state for annual token increase
            if (creatorSteez[creatorId].lastMintTime == 0 || (creatorSteez[creatorId].lastMintTime + oneYearInSeconds) <= block.timestamp) {
                creatorSteez[creatorId].lastMintTime = block.timestamp;
            }

            emit NewCreatorSteez(creatorId);

            // Take a snapshot after minting tokens
            ds.snapshotFacet.takeSnapshot();
        }

        // Pre-order function
        function preOrder(uint256 creatorId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarFacetAddress);
            require(creatorId[msg.sender], "CreatorToken: Only creators can initiate pre-orders.");
            require(!creatorSteez[creatorId].auctionConcluded, "CreatorToken: Auction has concluded.");
            creatorSteez[creatorId].totalSupply = ds.PRE_ORDER_SUPPLY;

            // Initialize auction start time if this is the first call
            if (creatorSteez[creatorId].auctionStartTime == 0) {
                creatorSteez[creatorId].auctionStartTime = block.timestamp;
            }

            require(block.timestamp < creatorSteez[creatorId].auctionStartTime + ds.AUCTION_DURATION, "CreatorToken: Auction duration has ended.");

            // Calculate required payment based on currentPrice and amount
            uint256 requiredPayment = creatorSteez[creatorId].currentPrice * amount;
            require(msg.value >= requiredPayment, "CreatorToken: Insufficient payment.");

            // Update auction state
            creatorSteez[creatorId].auctionSlotsSecured += amount;
            if (creatorSteez[creatorId].auctionSlotsSecured >= ds.PRE_ORDER_SUPPLY) {
                // Increment price for next batch and reset token count
                creatorSteez[creatorId].currentPrice += ds.PRICE_INCREMENT;
                creatorSteez[creatorId].auctionSlotsSecured = creatorSteez[creatorId].auctionSlotsSecured % ds.PRE_ORDER_SUPPLY; // Handle any excess tokens in this payment
            }

            // After 24 hours, conclude auction and release additional tokens at initial price
            if (block.timestamp >= creatorSteez[creatorId].auctionStartTime + ds.AUCTION_DURATION) {
                // Additional logic to mint and list ds.EXTRA_TOKENS_AFTER_AUCTION at INITIAL_PRICE
                // Consider a separate function to handle this if the logic is complex
                creatorSteez[creatorId].auctionConcluded = true;
            }

            // Refund excess payment
            uint256 excessPayment = msg.value - requiredPayment;
            if (excessPayment > 0) {
                payable(msg.sender).transfer(excessPayment);
            }
    
            // Mint tokens for the creator
            _mint(msg.sender, creatorId, creatorSteez[creatorId].steezId, amount, "");
            creatorSteez[creatorId].totalSupply += amount;

            emit PreOrderMinted(creatorId, msg.sender, amount);
            bazaarFacet.addLiquidityForToken(creatorId, amount, msg.value);
            launch(creatorId, amount);
        }

        // Launch function
        function launch(uint256 creatorId, uint256 amount) internal {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarFacetAddress);
            require(block.timestamp >= creatorSteez[creatorId].auctionStartTime + ds.AUCTION_DURATION, "Auction is still active");
            require(!creatorSteez[creatorId].auctionConcluded, "Auction has already been concluded");
            
            creatorSteez[creatorId].auctionConcluded = true;

            // Mint EXTRA_TOKENS_AFTER_AUCTION
            _mint(msg.sender, creatorId, creatorSteez[creatorId].steez, ds.EXTRA_TOKENS_AFTER_AUCTION, "");

            // List the minted tokens at INITIAL_PRICE
            // Assuming list is a function that lists the tokens at a given price
            bazaarFacet.listCreatorToken(creatorId, creatorSteez[creatorId].currentPrice);

            emit auctionConcluded(creatorId, creatorSteez[creatorId].currentPrice, creatorSteez[creatorId].totalSupply);

            // Launch token
            require(creatorSteez[creatorId].totalSupply > 0, "CreatorToken: Pre-order must be completed first.");
            require(creatorSteez[creatorId].totalSupply + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded.");
            require(amount > 0, "CreatorToken: Launch amount must be greater than zero");

            creatorSteez[creatorId].totalSupply = creatorSteez[creatorId].totalSupply + ds.LAUNCH_SUPPLY;
            _mint(msg.sender, creatorId, creatorSteez[creatorId].steezId, amount, "");
            creatorSteez[creatorId].totalSupply[creatorId] += amount;
            emit LaunchMinted(creatorId, msg.sender, creatorSteez[creatorId].totalSupply);
        }

        // Anniversary Expansion function
        function initiateAnniversary(uint256 creatorId, uint256 amount) external payable onlyOwner nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarFacetAddress);
            require(creatorSteez[creatorId].totalSupply > 0, "CreatorToken: Token does not exist");
            require(creatorSteez[creatorId].totalSupply + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded");
            require(creatorSteez[creatorId].transactionCount >= creatorSteez[creatorId].totalSupply * 2, "CreatorToken: Expansion not eligible");
            require(creatorId == msg.sender, "CreatorToken: Only the token creator can initiate an annual token increase.");
            require(block.timestamp >= creatorSteez[creatorId].lastMintTime + ds.ANNIVERSARY_DELAY, "CreatorToken: Annual token increase not yet available.");

            bazaarFacet.addLiquidity(creatorId, ds.EXPANSION_SUPPLY, creatorSteez[creatorId].currentPrice);

            uint256 currentSupply = creatorSteez[creatorId].totalSupply;
            uint256 newSupply = currentSupply + (currentSupply * ds.ANNUAL_TOKEN_INCREASE_PERCENTAGE / 100);
            creatorSteez[creatorId].totalSupply = newSupply;

            creatorSteez[creatorId].lastMintTime = block.timestamp;
            _mint(creatorId);
            emit AnniversaryMinted(creatorId);
        }

        // Transfer token balance and ownership to specified address
        function transferSteez(uint256 creatorId, uint256 steezId, uint256 amount, address from, address to) external nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            AccessControlFacet accessControl = AccessControlFacet(ds.accessControlAddress);
            SteezFeesFacet steezFees = SteezFeesFacet(ds.steezFeesFacetAddress);
            require(to != address(0), "CreatorToken: Transfer to zero address");
            require(from == msg.sender || accessControl.hasRole(ROLE_OPERATOR, msg.sender), "CreatorToken: Transfer caller is not owner nor approved");
            require(to != creatorId, "CreatorToken: Creator cannot buy their own token");
            require(from != to, "CreatorToken: Transfer to self");
            require(creatorSteez[creatorId].balances[from] >= amount, "CreatorToken: Transfer amount exceeds balance");

            address creator = creatorId;
            bool isCreator = creator == from && !(creatorSteez[creatorId].balances[from] > 0);

            // Update balances in diamond storage
            creatorSteez[creatorId].balances[to] += amount;
            creatorSteez[creatorId].balances[from] -= amount;

            // Transfer ownership
            creatorSteez[creatorId].investors = to;

            _transfer(from, to, creatorId);
            accessControl.grantRole(ROLE_OWNER, to);
            steezFeesFacet.payRoyalties(creatorId, amount, from, creatorSteez[creatorId].investors);

            if (creatorSteez[creatorId].balances[from] == 0) {
                _removeInvestor(creatorId, from);
                accessControl.revokeRole(ROLE_OWNER, from);
            }

            if (creatorSteez[creatorId].balances[to] > 0) {
                _addInvestor(creatorId, to);
            }

            // Emit SteezTransfer event
            emit SteezTransfer(from, to, creatorId, amount);
        }

        // Transfers multiple tokens of different types and amounts to different addresses, while checking for the recipient's ability to receive ERC1155
        function safeBatchTransfer(address[] memory to, uint256[] memory creatorIds, uint256[] memory amounts, bytes memory data) public {
            require(to.length == creatorIds.length && creatorIds.length == amounts.length, "CreatorToken: Arrays length must match");

            for (uint256 i = 0; i < to.length; i++) {
                safeTransferFrom(msg.sender, to[i], creatorIds[i], amounts[i], data);
            }
        }

        function _mint(address to, uint256 creatorId, uint256 steezId, uint256 amount, bytes memory data) internal {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            SteezFeesFacet steezFees = SteezFeesFacet(ds.steezFeesFacetAddress);
            for (uint256 i = 0; i < amount; i++) {
                _mint(to, creatorSteez[creatorId].steezId + i);
                creatorSteez[creatorId].steezId + i = to;
                steezFeesFacet.payRoyalties(creatorId, amount, creatorSteez[creatorId].investors);
            }
        }

        function _transfer(address from, address to, uint256 steezId) internal virtual {
            require(creatorSteez[creatorId].investor == from, "ERC721: transfer of token that is not own");
            require(to != address(0), "ERC721: transfer to the zero address");

            creatorSteez[steezId].balances[from] -= 1;
            creatorSteez[steezId].balances[to] += 1;
            creatorSteez[steezId].investors = to;

            emit SteezTransfer(from, to, steezId);
        }

        function _removeInvestor(uint256 creatorId, address currentInvestor) private {
            // Find the investor in the array
            uint256 investorIndex = _findInvestorIndex(creatorId, currentInvestor);
            require(investorIndex != uint256(-1), "This address does not own the token");

            // Remove the investor from the array
            uint256 lastIndex = creatorSteez[creatorId].investors.length - 1;
            creatorSteez[creatorId].investors[investorIndex] = creatorSteez[creatorId].investors[lastIndex];
            creatorSteez[creatorId].investors.pop();
        }

        function _addInvestor(uint256 creatorId, address newInvestor) private {
            // Check that the investor is not already in the array
            uint256 investorIndex = _findInvestorIndex(creatorId, newInvestor);
            require(investorIndex == uint256(-1), "This token is already owned");

            // Add the investor to the array
            Investor memory investor = Investor({
                profileId: 0, // Replace with actual profile ID
                balance: 0 // Replace with actual balance
            });
            creatorSteez[creatorId].investors.push(investor);
        }

        function _findInvestorIndex(uint256 creatorId, address investorAddress) private view returns (uint256) {
            for (uint256 i = 0; i < creatorSteez[creatorId].investors.length; i++) {
                if (creatorSteez[creatorId].investors[i].investorAddress == investorAddress) {
                    return i;
                }
            }
            return uint256(-1);
        }
}