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
    event Newsteez(address indexed creatorId);
    event TokenMinted(uint256 indexed creatorId, address indexed investors, uint256 amount);
    event PreOrderMinted(uint256 indexed creatorId, address indexed investors, uint256 amount);
    event auctionConcluded(uint256 creatorId, uint256 currentPrice, uint256 totalSupply);
    event LaunchCreated(uint256 indexed creatorId, uint256 currentPrice, uint256 totalSupply);
    event LaunchMinted(uint256 indexed creatorId, uint256 currentPrice, address indexed investors, uint256 amount);
    event AnniversaryMinted(uint256 indexed creatorId, uint256 totalSupply, uint256 currentPrice, address indexed investors, uint256 amount);
    event SteezTransfer(address indexed from, address indexed to, uint256 indexed steezId, uint256 amount, uint256 royaltyAmount);

    struct Investor {
        uint256 profileId; // ID of the investor's user profile
        address investorAddress; // address of the investor
        uint256 balance; // quantity of Steez owned by the investor
    }

    struct Royalty {
        uint256 totalRoyalties; // in Steelo, equiv. to 10% of the price of Steez transacted on Bazaar
        uint256 unclaimedRoyalties; // Total unclaimed royalties for this Steez
        uint256 creatorRoyalties; // in Steelo, equiv. to 5% of the price of Steez transacted on Bazaar
        uint256 investorRoyalties; // in Steelo, equiv. to 2.5% of the price of Steez transacted on Bazaar
        uint256 steeloRoyalties; // in Steelo, equiv. to 2.5% of the price of Steez transacted on Bazaar
        mapping(address => uint256) royaltyAmounts; // Mapping from investor address to the total amount of royalties received
        mapping(address => uint256[]) royaltyPayments; // Mapping from investor address to array of individual royalty payments received
    }
    
    struct Steez {
        uint256 creatorId; // one creatorId holds 500+ steezIds
        uint256 steezId; // mapping(creatorId => mapping(steezId => investors)
        uint256 totalSupply; // starting at 500 and increasing by 500 annually
        uint256 transactionCount; // drives anniversary requirements and $STEELO mint rate 
        uint256 lastMintTime; // to check when to next initiate Anniversary
        uint256 anniversaryDate; // to check when to next initiate Anniversary
        uint256 currentPrice; // determined by pre-order auction price, then via Supply x Demand AMM model
        uint256 auctionStartTime; // 250 out of the 500 initially minted tokens for pre-order
        uint256 auctionSlotsSecured; // increments price by £10 every 250 token auctions at new price 
        string baseURI; // base URI for token metadata
        bool creatorExists; // only one steez per creator
        bool auctionConcluded; // 24hr auction after 1 week of pre-order
        Investor[] investors; // investors array updated to show "current holders"
        Royalty royalties; // Integrated Royalty struct for managing royalties
    }

    mapping(address => Steez) public steez;

    uint256 oneYearInSeconds = 365 days;
    uint256 oneWeekInSeconds = 7 days;
    uint256 private _lastCreatorId;
    uint256 private _lastProfileId;
    uint256 private _lastSteezId;
    string public baseURI;

    modifier canCreateToken(address creator) {
        require(!steez[creator].creatorExists, "CreatorToken: Creator has already created a token.");
        _;
    }

    modifier withinAuctionPeriod() {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        require(Steez[steez].auctionStartTime != 0, "Auction has not started yet");
        require(block.timestamp < Steez[steez].auctionStartTime + ds.AUCTION_DURATION, "Auction duration has ended");
        _;
    }

    // FUNCTIONS
    function initialize(string memory _baseURI) public initializer {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        steezFacetAddress = ds.steezFacetAddress;
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
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            SnapshotFacet snapshot = SnapshotFacet(ds.snapshotFacetAddress);
            require(canCreateToken(msg.sender), "CreatorToken: Creator has already created a token.");
            require(Steez[steez].creatorId != 0, "CreatorToken: Token ID cannot be 0");
            require(Steez[steez].creatorId.current() < type(uint256).max, "CreatorToken: creator overflow");
            require(to != address(0), "CreatorToken: Cannot mint to zero address");
            require(!Steez[steez].creatorExists, "CreatorToken: token already exists");

            Investor memory newInvestor = Investor({
                profileId: _lastProfileId++ ,// ID of the investor's user profile
                investorAddress: msg.sender,
                balance: 0 // initial balance
            });

            Royalty memory newRoyalty = Royalty ({
                totalRoyalties: 0, // needs to be the same value for royalties associated to the same SteezId
                unclaimedRoyalties: 0, // needs to be the same value for royalties associated to the same SteezId
                creatorRoyalties: 0, // initial balance
                investorRoyalties: 0, // initial balance
                steeloRoyalties: 0, // initial balance
                royaltyAmounts: 0, // initial balance
                royaltyPayments: 0 // initial balance
            });
    
            Steez memory steez = Steez({
                creatorId:_lastCreatorId++, // = profileId
                steezId: _lastSteezId++, // increment _lastCreatorId for each new Steez
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

            steez[msg.sender] = steez; // stores steez object in steez mapping
         
            uint256 creatorId = _lastCreatorId;
            uint256 profileId = _lastProfileId;
            uint256 steezId = _lastSteezId;

            _mint(to, creatorId, steez[creatorId].steezId, data);

            // Update the minting state for annual token increase
            if (steez[creatorId].lastMintTime == 0 || (steez[creatorId].lastMintTime + oneYearInSeconds) <= block.timestamp) {
                steez[creatorId].lastMintTime = block.timestamp;
            }

            emit Newsteez(creatorId);

            // Take a snapshot after minting tokens
            snapshot.takeSnapshot();
        }

        // Pre-order function
        function preOrder(uint256 creatorId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarAddress);
            require(creatorId[msg.sender], "CreatorToken: Only creators can initiate pre-orders.");
            require(!steez[creatorId].auctionConcluded, "CreatorToken: Auction has concluded.");
            steez[creatorId].totalSupply = ds.PRE_ORDER_SUPPLY;

            // Initialize auction start time if this is the first call
            if (steez[creatorId].auctionStartTime == 0) {
                steez[creatorId].auctionStartTime = block.timestamp;
            }

            require(block.timestamp < steez[creatorId].auctionStartTime + ds.AUCTION_DURATION, "CreatorToken: Auction duration has ended.");

            // Calculate required payment based on currentPrice and amount
            uint256 requiredPayment = steez[creatorId].currentPrice * amount;
            require(msg.value >= requiredPayment, "CreatorToken: Insufficient payment.");

            // Update auction state
            steez[creatorId].auctionSlotsSecured += amount;
            if (steez[creatorId].auctionSlotsSecured >= ds.PRE_ORDER_SUPPLY) {
                // Increment price for next batch and reset token count
                steez[creatorId].currentPrice += ds.PRICE_INCREMENT;
                steez[creatorId].auctionSlotsSecured = steez[creatorId].auctionSlotsSecured % ds.PRE_ORDER_SUPPLY; // Handle any excess tokens in this payment
            }

            // After 24 hours, conclude auction and release additional tokens at initial price
            if (block.timestamp >= steez[creatorId].auctionStartTime + ds.AUCTION_DURATION) {
                // Additional logic to mint and list ds.EXTRA_TOKENS_AFTER_AUCTION at INITIAL_PRICE
                // Consider a separate function to handle this if the logic is complex
                steez[creatorId].auctionConcluded = true;
            }

            // Refund excess payment
            uint256 excessPayment = msg.value - requiredPayment;
            if (excessPayment > 0) {
                payable(msg.sender).transfer(excessPayment);
            }
    
            // Mint tokens for the creator
            _mint(msg.sender, creatorId, steez[creatorId].steezId, amount, "");
            steez[creatorId].totalSupply += amount;

            emit PreOrderMinted(creatorId, msg.sender, amount);
            bazaar.addLiquidityForToken(creatorId, amount, msg.value);
            launch(creatorId, amount);
        }

        // Launch function
        function launch(uint256 creatorId, uint256 amount) internal {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarAddress);
            require(block.timestamp >= steez[creatorId].auctionStartTime + ds.AUCTION_DURATION, "Auction is still active");
            require(!steez[creatorId].auctionConcluded, "Auction has already been concluded");
            
            steez[creatorId].auctionConcluded = true;

            // Mint EXTRA_TOKENS_AFTER_AUCTION
            _mint(msg.sender, creatorId, steez[creatorId].steez, ds.EXTRA_TOKENS_AFTER_AUCTION, "");

            // List the minted tokens at INITIAL_PRICE
            bazaar.listCreatorToken(creatorId, steez[creatorId].currentPrice);

            emit auctionConcluded(creatorId, steez[creatorId].currentPrice, steez[creatorId].totalSupply);

            // Launch token
            require(steez[creatorId].totalSupply > 0, "CreatorToken: Pre-order must be completed first.");
            require(steez[creatorId].totalSupply + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded.");
            require(amount > 0, "CreatorToken: Launch amount must be greater than zero");

            steez[creatorId].totalSupply = steez[creatorId].totalSupply + ds.LAUNCH_SUPPLY;
            _mint(msg.sender, creatorId, steez[creatorId].steezId, amount, "");
            steez[creatorId].totalSupply[creatorId] += amount;
            emit LaunchMinted(creatorId, msg.sender, steez[creatorId].totalSupply);
        }

        // Anniversary Expansion function
        function anniversary(uint256 creatorId, uint256 amount) external payable onlyOwner nonReentrant {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            BazaarFacet bazaar = BazaarFacet(ds.bazaarAddress);
            require(steez[creatorId].totalSupply > 0, "CreatorToken: Token does not exist");
            require(steez[creatorId].totalSupply + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded");
            require(steez[creatorId].transactionCount >= steez[creatorId].totalSupply * 2, "CreatorToken: Expansion not eligible");
            require(creatorId == msg.sender, "CreatorToken: Only the token creator can initiate an annual token increase.");
            require(block.timestamp >= steez[creatorId].lastMintTime + ds.ANNIVERSARY_DELAY, "CreatorToken: Annual token increase not yet available.");

            bazaar.addLiquidity(creatorId, ds.EXPANSION_SUPPLY, steez[creatorId].currentPrice);

            uint256 currentSupply = steez[creatorId].totalSupply;
            uint256 newSupply = currentSupply + (currentSupply * ds.ANNUAL_TOKEN_INCREASE_PERCENTAGE / 100);
            steez[creatorId].totalSupply = newSupply;

            steez[creatorId].lastMintTime = block.timestamp;
            _mint(creatorId);
            emit AnniversaryMinted(creatorId);
        }

        // Transfer token balance and ownership to specified address
        function transferSteez(uint256 creatorId, uint256 steezId, uint256 amount, address from, address to) external nonReentrant {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            AccessControlFacet accessControl = AccessControlFacet(ds.accessControlAddress);
            SteezFeesFacet steezFees = SteezFeesFacet(ds.steezFeesAddress);
            require(to != address(0), "CreatorToken: Transfer to zero address");
            require(from == msg.sender || accessControl.hasRole(ROLE_OPERATOR, msg.sender), "CreatorToken: Transfer caller is not owner nor approved");
            require(to != creatorId, "CreatorToken: Creator cannot buy their own token");
            require(from != to, "CreatorToken: Transfer to self");
            require(steez[creatorId].balances[from] >= amount, "CreatorToken: Transfer amount exceeds balance");

            address creator = creatorId;
            bool isCreator = creator == from && !(steez[creatorId].balances[from] > 0);

            // Update balances in diamond storage
            steez[creatorId].balances[from] -= amount;
            steez[creatorId].balances[to] += amount;

            // Transfer ownership
            steez[creatorId].investors = to;

            _transfer(from, to, creatorId);
            accessControl.grantRole(ROLE_OWNER, to);
            steezFees.payRoyalties(creatorId, amount, from, steez[creatorId].investors);

            if (steez[creatorId].balances[from] == 0) {
                _removeInvestor(creatorId, from);
                accessControl.revokeRole(ROLE_OWNER, from);
            }

            if (steez[creatorId].balances[to] > 0) {
                _addInvestor(creatorId, to);
            }

            // Emit SteezTransfer event
            emit SteezTransfer(from, to, creatorId, amount);
        }

        function safeBatchTransfer(address[] memory to, uint256[] memory creatorIds, uint256[] memory amounts, bytes memory data) public {
            require(to.length == creatorIds.length && creatorIds.length == amounts.length, "CreatorToken: Arrays length must match");

            for (uint256 i = 0; i < to.length; i++) {
                safeTransferFrom(msg.sender, to[i], creatorIds[i], amounts[i], data);
            }
        }

        function _mint(address to, uint256 creatorId, uint256 steezId, uint256 amount, bytes memory data) internal {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            SteezFeesFacet steezFees = SteezFeesFacet(ds.steezFeesAddress);
            for (uint256 i = 0; i < amount; i++) {
                _mint(to, steez[creatorId].steezId + i);
                steez[creatorId].steezId + i = to;
                steezFees.payRoyalties(creatorId, amount, steez[creatorId].investors);
            }
        }

        function _transfer(address from, address to, uint256 steezId) internal virtual {
            require(to != address(0), "ERC721: transfer to the zero address");

            Steez storage steez = steez[steezId];
            bool isInvestor = false;
            uint i;
            for (i = 0; i < steez.investors.length; i++) {
                if (steez.investors[i].investorAddress == from) {
                    isInvestor = true;
                    break;
                }
            }
            require(isInvestor, "ERC721: transfer of token that is not own");

            steez.balances[from] -= 1;
            steez.balances[to] += 1;

            if (isInvestor) {
                steez.investors[i].investorAddress = to;
            }
            emit SteezTransfer(from, to, steezId);
        }

        function _removeInvestor(uint256 creatorId, address currentInvestor) private {
            // Find the investor in the array
            uint256 investorIndex = _findInvestorIndex(creatorId, currentInvestor);
            require(investorIndex != uint256(-1), "This address does not own the token");

            // Remove the investor from the array
            uint256 lastIndex = steez[creatorId].investors.length - 1;
            steez[creatorId].investors[investorIndex] = steez[creatorId].investors[lastIndex];
            steez[creatorId].investors.pop();
        }

        function _addInvestor(uint256 creatorId, address newInvestor, uint256 profileId, uint256 balance) private {
            // Check that the investor is not already in the array
            uint256 investorIndex = _findInvestorIndex(creatorId, newInvestor);
            require(investorIndex == uint256(-1), "This token is already owned");

            // Add the investor to the array
            Investor memory investor = Investor({
                profileId: profileId, // Use the provided profile ID
                balance: balance // Use the provided balance
            });
            steez[creatorId].investors.push(investor);
        }

        function _findInvestorIndex(uint256 creatorId, address investorAddress) private view returns (uint256) {
            for (uint256 i = 0; i < steez[creatorId].investors.length; i++) {
                if (steez[creatorId].investors[i].investorAddress == investorAddress) {
                    return i;
                }
            }
            return uint256(-1);
        }
}