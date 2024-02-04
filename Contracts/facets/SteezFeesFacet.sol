// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "node_modules/@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./STEEZFacet.sol";

interface ISTEEZFacet {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    function creatorOf(uint256 tokenId) external view returns (address);   
    function ownerOf(uint256 tokenId, uint256 index) external view returns (address);
    function isOwnerOf(address account, uint256 tokenId) external view returns (bool);
    function totalSupply(uint256 tokenId) external view returns (uint256);
    function balanceOf(address account, uint256 tokenId) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
    function uri(uint256 tokenId) external view returns (string memory);
    function mint(address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
    function burn(address account, uint256 tokenId, uint256 amount) external;
}

struct Snapshot {
    uint256 blockNumber;
    uint256 value;
}

// Royalties.sol is a facet contract that implements the royalty logic and data for the SteeloToken contract
contract Royalties is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;

    // Constants for the royalty rates during Pre-Orders
    uint256 constant PRE_ORDER_CREATOR_RATE = 90; // 90% of pre-order sale value to creator
    uint256 constant PRE_ORDER_STEELO_RATE = 10; // 10% of pre-order sale value to Steelo

    // Constants for the royalty rates during Token Launch and Expansions
    uint256 constant LAUNCH_CREATOR_RATE = 90; // 90% of launch + expansion sale value to creator
    uint256 constant LAUNCH_STEELO_RATE = 75; // 7.5% of launch + expansion sale value to Steelo
    uint256 constant LAUNCH_COMMUNITY_RATE = 25; // 2.5% of launch + expansion sale value to token holders
    
    // Constants for the royalty rates for any 2nd hand sales
    uint256 constant SECOND_HAND_SELLER_RATE = 90; // 90% of second-hand sale value to seller
    uint256 constant SECOND_HAND_CREATOR_RATE = 50; // 5% of second-hand sale value to creator
    uint256 constant SECOND_HAND_STEELO_RATE = 25; // 2.5% of second-hand sale value to Steelo
    uint256 constant SECOND_HAND_COMMUNITY_RATE = 25; // 2.5% of second-hand sale value to token holders

// MAPPING

    // Mapping from token ID to mapping of user address to their share of undistributed community royalties
    mapping (uint256 => mapping(address => uint256)) private _undistributedRoyalties;

    // Mapping for storing the community royalty rate for each token ID
    mapping (uint256 => uint256) private _communityRoyaltyRates;

    // Mapping from token ID to mapping of user address to an array of snapshots
    mapping(uint256 => mapping(address => Snapshot[])) private _holderSnapshots;

    // Mapping from token ID to an array of snapshots for the total undistributed community royalties
    mapping(uint256 => Snapshot[]) private _totalUndistributedSnapshots;

// EVENTS

    // Event emitted when a royalty is paid to a recipient
    event RoyaltyPaid(uint256 indexed tokenId, address indexed recipient, uint256 amount);

    // Event emitted when a token is transferred on CreatorToken.sol
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

// MODIFIERS

    // Modifier to pay royalties for a token transfer
    modifier payRoyaltiesOnTransfer(uint256 id, uint256 value, address from, address to) {
        _;
        payRoyalties(id, value, from, to);
    }

    modifier onlyAdmin() {
        require(ISTEEZFacet(_creatorTokenAddress).isAdmin(msg.sender), "Royalties: Caller is not an admin");
        _;
    }

// CONTRACT ADDRESSES
    address private _creatorTokenAddress;

// FUNCTIONS

    // Function to initialize the contract with the owner address
    function initialize(address owner) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        transferOwnership(owner);
    }

    // Function to listen to ownership events from CreatorToken.sol
    function setCreatorTokenAddress(address creatorTokenAddress) external onlyOwner {
        _creatorTokenAddress = creatorTokenAddress;
        ISTEEZFacet(_creatorTokenAddress).TransferSingle().add(this.onTransferSingle.selector);
    }

    // Function to listen to transaction events from CreatorToken.sol
    function onTransferSingle(address operator, address from, address to, uint256 id, uint256 value) external {
        require(msg.sender == _creatorTokenAddress, "Royalties: Caller is not the CreatorToken contract");
        payRoyalties(id, value, from, to);
    }

    // Function to create a snapshot for a token
    function createSnapshot(uint256 tokenId) external onlyAdmin {
        uint256 totalUndistributed = _undistributedRoyalties[tokenId][address(this)];
        uint256 blockNumber = block.number;
        _totalUndistributedSnapshots[tokenId].push(Snapshot(blockNumber, totalUndistributed));

        // Iterate through the holders and create a snapshot for each one
        CreatorToken parent = CreatorToken(owner());
        uint256 totalSupply = parent.totalSupply(tokenId);

        for (uint256 i = 0; i < totalSupply; i++) {
            address holder = parent.ownerOf(tokenId, i);
            uint256 holderBalance = parent.balanceOf(holder, tokenId);
            _holderSnapshots[tokenId][holder].push(Snapshot(blockNumber, holderBalance));
        }
    }

    // Function to distribute community royalties for a token
    function distributeCommunityRoyalties(uint256 tokenId) external {
        require(tokenId > 0, "Royalties: Invalid token ID");

        CreatorToken parent = CreatorToken(owner());
        uint256 totalSupply = parent.totalSupply(tokenId);
        require(totalSupply > 0, "Royalties: Token has no supply");

        uint256 communityRoyalty = _communityRoyaltyRates[tokenId];
        require(communityRoyalty > 0, "Royalties: Token has no community royalty");

        // Calculate the share of each token holder based on their balance and the undistributed royalties
        uint256 sharePerToken = _undistributedRoyalties[tokenId][address(this)].div(totalSupply);
        for (uint256 i = 0; i < totalSupply; i++) {
            address holder = parent.ownerOf(tokenId, i);
            uint256 balance = parent.balanceOf(holder, tokenId);
            uint256 share = sharePerToken.mul(balance);
            _undistributedRoyalties[tokenId][holder] = _undistributedRoyalties[tokenId][holder].add(share);
            _undistributedRoyalties[tokenId][address(this)] = _undistributedRoyalties[tokenId][address(this)].sub(share);
        }
    }

    // Function to claim community royalties for a token
    function claimCommunityRoyalties(uint256 tokenId) external nonReentrant {
        require(tokenId > 0, "Royalties: Invalid token ID");

        // Find the correct snapshot for the holder and the total undistributed royalties
        uint256 holderSnapshotIndex = _findSnapshotIndex(tokenId, msg.sender);
        uint256 totalSnapshotIndex = _findSnapshotIndex(tokenId, address(this));

        uint256 holderBalance = _holderSnapshots[tokenId][msg.sender][holderSnapshotIndex].value;
        uint256 totalUndistributed = _totalUndistributedSnapshots[tokenId][totalSnapshotIndex].value;
        uint256 holderShare = totalUndistributed.mul(holderBalance).div(totalSupply);

        require(holderShare > 0, "Royalties: No royalties to claim");

        // Transfer the royalties to the token holder
        payable(msg.sender).transfer(holderShare);

        // Update the undistributed royalties
        _undistributedRoyalties[tokenId][msg.sender] = _undistributedRoyalties[tokenId][msg.sender].sub(holderShare);
        _undistributedRoyalties[tokenId][address(this)] = _undistributedRoyalties[tokenId][address(this)].sub(holderShare);
    }

    // Function to pay royalties for a token transfer (triggered by the TransferSingle event on CreatorToken.sol)
    function payRoyalties(uint256 tokenId, uint256 salePrice, address seller, address buyer) external payable {
        require(tokenId > 0, "Royalties: Invalid token ID");
        require(salePrice > 0, "Royalties: Invalid sale price");
        require(msg.value >= salePrice, "Royalties: Insufficient payment");
        require(msg.sender == owner(), "Royalties: Caller is not the owner");
        _communityRoyaltyRates[tokenId] = communityRate;

        uint256 creatorRate;
        uint256 steeloRate;
        uint256 communityRate;

        if (seller == owner()) {
            if (buyer == owner()) {
                creatorRate = PRE_ORDER_CREATOR_RATE; // pre-order sale
                steeloRate = PRE_ORDER_STEELO_RATE;
                communityRate = 0;
            } else {
                creatorRate = LAUNCH_CREATOR_RATE; // launch or expansion sale
                steeloRate = LAUNCH_STEELO_RATE;
                communityRate = LAUNCH_COMMUNITY_RATE;
            }
        } else {
            creatorRate = SECOND_HAND_CREATOR_RATE; // second-hand sale
            steeloRate = SECOND_HAND_STEELO_RATE;
            communityRate = SECOND_HAND_COMMUNITY_RATE;
        }

        // Pay the creator royalty
        uint256 creatorAmount = salePrice.mul(creatorRate).div(1000); // divide by 1000 to get correct percentage
        payable(seller).transfer(creatorAmount);

        // Pay the Steelo royalty
        uint256 steeloAmount = salePrice.mul(steeloRate).div(1000); // divide by 1000 to get correct percentage
        payable(owner()).transfer(steeloAmount);

        // Add the community royalty to the undistributed pool
        uint256 communityAmount = salePrice.mul(communityRate).div(1000); // divide by 1000 to get correct percentage
        _undistributedRoyalties[tokenId][address(this)] = _undistributedRoyalties[tokenId][address(this)].add(communityAmount);

        // Pay the seller royalty (only for second-hand sales)
        if (seller != owner()) {
            uint256 sellerAmount = salePrice.mul(SECOND_HAND_SELLER_RATE).div(1000); // divide by 1000 to get correct percentage
            payable(seller).transfer(sellerAmount);
        }
    }

    // Helper function to find the correct snapshot index
    function _findSnapshotIndex(uint256 tokenId, address account) private view returns (uint256) {
        Snapshot[] storage snapshots = _holderSnapshots[tokenId][account];
        uint256 left = 0;
        uint256 right = snapshots.length;

        while (left < right) {
            uint256 mid = left.add(right).div(2);
            if (snapshots[mid].blockNumber <= block.number) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return left.sub(1);
    }
}