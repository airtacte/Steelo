// SPDX-License-Identifier: MIT
// contracts/DiamondCutFacet.sol
pragma solidity ^0.8.19;

import "node_modules/@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "./CreatorToken.sol";

// Royalties.sol is a facet contract that implements the royalty logic and data for the SteeloToken contract
contract Royalties is OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    // Returns array for the functions to be added as facts to the diamond contract
    function getSelectors() public pure returns (bytes4[] memory) {
        return [
            this.setRoyalties.selector, // Add more function selectors as needed
            this.getRoyalties.selector
        ];
    }

    // Constants for the royalty rates
    uint256 constant PRE_ORDER_RATE = 90; // 90% of sale value to creator
    uint256 constant LAUNCH_RATE = 90; // 90% of sale value to creator
    uint256 constant SECOND_HAND_RATE = 90; // 90% of sale value to seller
    uint256 constant EXPANSION_RATE = 90; // 90% of sale value to creator
    uint256 constant STEELO_RATE = 10; // 10% of pre-order sale value to Steelo
    uint256 constant COMMUNITY_RATE = 25; // 2.5% of launch, second-hand and expansion sale value to token holders
    uint256 constant CREATOR_RATE = 50; // 5% of second-hand sale value to creator

    // Mapping from token ID to mapping of user address to their share of undistributed community royalties
    mapping (uint256 => mapping(address => uint256)) private _undistributedRoyalties;

    // Event emitted when a royalty is paid to a recipient
    event RoyaltyPaid(uint256 indexed tokenId, address indexed recipient, uint256 amount);

    // Event emitted when a token is transferred on CreatorToken.sol
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    // Modifier to pay royalties for a token transfer
    modifier payRoyaltiesOnTransfer(uint256 id, uint256 value, address from, address to) {
        _;
        payRoyalties(id, value, from, to);
    }

    // Function to initialize the contract with the owner address
    function initialize(address owner) public initializer {
        __Ownable_init();
        transferOwnership(owner);
    }

    // Function to distribute community royalties for a token
    function distributeCommunityRoyalties(uint256 tokenId) external {
        require(tokenId > 0, "Royalties: Invalid token ID");

        CreatorToken parent = CreatorToken(owner());
        uint256 totalSupply = parent.totalSupply(tokenId);
        require(totalSupply > 0, "Royalties: Token has no supply");

        uint256 communityRoyalty = COMMUNITY_RATE;
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
    function claimCommunityRoyalties(uint256 tokenId) external {
        require(tokenId > 0, "Royalties: Invalid token ID");

        uint256 amount = _undistributedRoyalties[tokenId][msg.sender];
        require(amount > 0, "Royalties: No royalties to claim");

        // Transfer the royalties to the token holder
        payable(msg.sender).transfer(amount);

        // Update the undistributed royalties
        _undistributedRoyalties[tokenId][msg.sender] = 0;
    }

    // Function to pay royalties for a token transfer (triggered by the TransferSingle event on CreatorToken.sol)
    function payRoyalties(uint256 tokenId, uint256 salePrice, address seller, address buyer) external payable {
        require(tokenId > 0, "Royalties: Invalid token ID");
        require(salePrice > 0, "Royalties: Invalid sale price");
        require(msg.value >= salePrice, "Royalties: Insufficient payment");
        require(msg.sender == owner(), "Royalties: Caller is not the owner");

        // Determine the royalty rate based on the sale type
        uint256 rate;
        if (seller == owner()) {
            if (buyer == owner()) {
                rate = PRE_ORDER_RATE; // pre-order sale
            } else {
                rate = LAUNCH_RATE; // launch or expansion sale
            }
        } else {
            rate = SECOND_HAND_RATE; // second-hand sale
        }

        // Pay the seller royalty
        uint256 sellerAmount = salePrice.mul(rate).div(100);
        payable(seller).transfer(sellerAmount);

        // Pay the Steelo royalty
        uint256 steeloAmount = salePrice.mul(STEELO_RATE).div(100);
        payable(owner()).transfer(steeloAmount);

        // Add the community royalty to the undistributed pool
        uint256 communityAmount = salePrice.mul(COMMUNITY_RATE).div(1000); // divide by 1000 to get 2.5%
        _undistributedRoyalties[tokenId][address(this)] = _undistributedRoyalties[tokenId][address(this)].add(communityAmount);

        // Pay the creator royalty (only for second-hand sales)
        if (rate == SECOND_HAND_RATE) {
            address creator = CreatorToken(owner()).creatorOf(tokenId);
            uint256 creatorAmount = salePrice.mul(CREATOR_RATE).div(1000); // divide by 1000 to get 5%
            payable(creator).transfer(creatorAmount);
        }
    }
}