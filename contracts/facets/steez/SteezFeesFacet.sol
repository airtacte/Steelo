// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { STEEZFacet } from "./STEEZFacet.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { SnapshotFacet } from "../app/SnapshotFacet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract SteezFeesFacet is ERC1155Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    struct RoyaltyInfo {
        address creator;
        address investors;
        uint256 share;
        uint256 value;
    }
    

    event RoyaltiesDistributed(uint256 indexed creatorId, address indexed investors, uint256 amount);
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event DistributionPolicySet(uint256 creatorId, address investors, uint256 share);

    mapping(uint256 => uint256[]) public communitySplits;
    mapping(uint256 => mapping(address => uint256)) public balances;

    modifier onlyAdmin() {
        require(AccessControlFacet.diamondStorage().isAdmin[msg.sender], "Royalties: Caller is not an admin");
        _;
    }
    
    function initialize(address owner) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        transferOwnership(owner);
    }

        function setCommunitySplit(uint256 creatorId, uint256[] memory splits) external onlyOwner {
            // Ensure the sum of splits is 100
            uint256 total = 0;
            for (uint256 i = 0; i < splits.length; i++) {
                total += splits[i];
            }
            require(total == 100, "Total split must be 100");

            // Store the splits
            communitySplits[creatorId] = splits;
        }

        function payRoyalties(uint256 creatorId, uint256 amount, address from, address to, bytes memory data) external payable nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            STEEZFacet steez = STEEZFacet(ds.steezFacetAddress);
            require(creatorId > 0, "Royalties: Invalid token ID");
            require(amount > 0, "CreatorToken: Transfer amount must be greater than zero");
            require(msg.value >= amount, "Royalties: Insufficient payment");
            require(msg.sender == owner(), "Royalties: Caller is not the owner");

            // Called by steezFeesFacet.payRoyalties(creatorId, amount, from, creatorSteez[creatorId].investors);
            // From STEEZFeesFacet.sol's function transferSteez(uint256 creatorId, uint256 steezId, uint256 amount, address from, address to) external nonReentrant {

            uint256 creatorRate;
            uint256 steeloRate;
            uint256 communityRate;


            if (from == owner()) {
                if (to == owner()) {
                    creatorRate = ds.PRE_ORDER_CREATOR_RATE;
                    steeloRate = ds.PRE_ORDER_STEELO_RATE;
                    communityRate = 0;
                } else {
                    creatorRate = ds.LAUNCH_CREATOR_RATE;
                    steeloRate = ds.LAUNCH_STEELO_RATE;
                    communityRate = ds.LAUNCH_COMMUNITY_RATE;
                }
            } else {
                creatorRate = ds.SECOND_HAND_CREATOR_RATE;
                steeloRate = ds.SECOND_HAND_STEELO_RATE;
                communityRate = ds.SECOND_HAND_COMMUNITY_RATE;
            }

            // Calculate the royalty amounts
            uint256 creatorFee = (amount * creatorRate) / 100;
            uint256 steeloFee = (amount * steeloRate) / 100;
            uint256 communityFee = (amount * communityRate) / 100;
            uint256 totalRoyalty = creatorFee + steeloFee + communityFee;
            require(totalRoyalty <= amount, "Royalties: Royalty exceeds transfer amount");

            // Pay the creator royalty
            (bool sent, ) = payable(from).call{value: creatorFee}("");
            require(sent, "Failed to send Ether");
            payable(owner()).transfer(steeloFee);

            // Distribute the community royalty among investors
            for (uint256 i = 0; i < steez.investors.length; i++) {
                uint256 balance = steez.balance;
                uint256 share = steez.totalSupply > 0 ? (communityFee * balance) / steez.totalSupply : 0;
                payable(steez.investors[i]).transfer(share);
            }

            // Ensure royalties are distributed correctly
            uint256 fromBalance = steez.balance;
            require(fromBalance >= amount, "Royalties: Insufficient balance");
            uint256 fromBalanceAfterTransfer = fromBalance.sub(amount);
            require(amount - creatorFee - steeloFee - communityFee > 0, "Royalties: Insufficient amount for seller");

            // Pay the seller royalty (only for second-hand sales)
            if (from != owner()) {
                uint256 sellerFee = (amount * ds.SECOND_HAND_SELLER_RATE)/1000;
                payable(from).transfer(sellerFee);
            }

            // Update balances in diamond storage
            steez.balance -= amount;
            steez.balance += amount;

            // Update creator and contract balances for royalties
            steez.balance += creatorFee;
            steez.balance += steeloFee;

            emit RoyaltiesDistributed(from, to, creatorId, amount, creatorFee, steeloFee, communityFee, data);
        }

        function claimRoyalty(uint256 creatorId) external nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            SnapshotFacet snapshot = SnapshotFacet(ds.snapshotFacetAddress);
            require(creatorId > 0, "Royalties: Invalid token ID");

            // Find the correct snapshot for the investor and the total undistributed royalties
            uint256 investorSnapshotIndex = snapshot.findSnapshotIndex(creatorId, msg.sender);
            uint256 totalSnapshotIndex = snapshot.findSnapshotIndex(creatorId, address(this));

            uint256 investorBalance = snapshot.investorSnapshots(creatorId, msg.sender, investorSnapshotIndex);
            uint256 totalUndistributed = snapshot.totalUndistributedSnapshots(creatorId, totalSnapshotIndex);
            uint256 totalSupply = snapshot.totalSupply(creatorId);
            uint256 investorShare = (totalUndistributed * investorBalance) / totalSupply;

            require(investorShare > 0, "Royalties: No royalties to claim");

            // Transfer the royalties to the token investor
            payable(msg.sender).transfer(investorShare);
        }

        function viewRoyalties(address user, uint256 creatorId) public view returns (uint256 userShare, uint256 userRoyalty) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            STEEZFacet.Steez memory steez = STEEZFacet(ds.steezFacetAddress).steez(creatorId);

            if (steez.totalSupply == 0 || steez.balance == 0) {
                return (0, 0);
            }

            // Calculate user's share of the royalty
            userShare = (steez.royalty * steez.balance) / steez.totalSupply;

            // Calculate user's total royalty
            uint256 userSharePercentage = (steez.balance * 10000) / steez.totalSupply;
            userRoyalty = (steez.creatorRoyalty * userSharePercentage)/10000;

            if (user == steez.creator) {
                userRoyalty = userRoyalty + steez.creatorRoyalty;
            } else {
                userRoyalty = userRoyalty + steez.steeloRoyalty;
            }

            userRoyalty = userRoyalty + steez.undistributedRoyalty;

            return (userShare, userRoyalty);
        }
}