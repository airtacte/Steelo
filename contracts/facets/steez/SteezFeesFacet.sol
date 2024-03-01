// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { STEEZFacet } from "./STEEZFacet.sol";
import { STEELOFacet } from "../steelo/STEELOFacet.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { SnapshotFacet } from "../app/SnapshotFacet.sol"; // To setup 
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract SteezFeesFacet is ERC1155Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    STEEZFacet.Steez public steez; // Imported Steez struct from STEEZFacet. Represents a Steez and its related properties.
    STEEZFacet.Investor public investor; // Imported Investor struct from STEEZFacet. Represents an investor in the Steez.
    STEEZFacet.Royalty public royalty; // Imported Royalty struct from STEEZFacet. Represents the royalties related to a Steez.
 
    event TransferProcessed(uint256 indexed steezId, address indexed from, address indexed to, uint256 amount, uint256 royaltyAmount);
    event ShareholderUpdated(uint256 indexed steezId, address indexed shareholder, uint256 balance);
    event RoyaltiesDistributed(
        address indexed from, address indexed to, 
        uint256 indexed creatorId, uint256 amount, 
        uint256 creatorFee, uint256 steeloFee, uint256 communityFee, 
        bytes data
        
    );

    modifier onlyAdmin() {
        require(AccessControlFacet.diamondStorage().isAdmin[msg.sender], "Royalties: Caller is not an admin");
        _;
    }
    
    function initialize(address owner) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        transferOwnership(owner);
    }

        function updateRoyaltyInfo(uint256 creatorId, uint256 amount) internal {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            STEEZFacet.Steez storage localSteez = STEEZFacet(address(this)).creatorSteez(creatorId);
            AccessControlFacet accessControl = AccessControlFacet(ds.accessControlAddress);
            require(msg.sender == address(this) || accessControl.isAuthorized(msg.sender), "Unauthorized");
            localSteez.royalties.totalRoyalties += amount;
            // Additional logic here
        }

        function setCommunitySplit(uint256 creatorId, uint256[] memory splits) external onlyOwner {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            STEEZFacet.Steez storage localSteez = STEEZFacet(address(this)).creatorSteez(creatorId);
 
            // Ensure the sum of splits is 100
            uint256 total = 0;
            for (uint256 i = 0; i < splits.length; i++) {
                total += splits[i];
            }
            require(total == 100, "Total split must be 100");

            // Store the splits
            localSteez.royalties.shareholderRoyalties[creatorId] = splits;
        }

        // Called by STEEZFacet.payRoyalties(creatorId, amount, from, creatorSteez[creatorId].investors);
        // From its function transferSteez(uint256 creatorId, uint256 creatorId, uint256 amount, address from, address to) external nonReentrant {
        function payRoyalties(uint256 creatorId, uint256 amount, address from, address to, bytes memory data) external payable nonReentrant {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            STEEZFacet.Steez storage localSteez = STEEZFacet(address(this)).creatorSteez(creatorId);
            require(creatorId > 0, "Royalties: Invalid token ID");
            require(amount > 0, "CreatorToken: Transfer amount must be greater than zero");
            require(msg.value >= amount, "Royalties: Insufficient payment");
            require(msg.sender == owner(), "Royalties: Caller is not the owner");

            uint256 creatorRate; // 90% of pre-orders, 90% of launch/expansions, 5% of second-hand
            uint256 steeloRate; // 10% of pre-orders, 7.5% of launch/expansions, 2.5% of second-hand
            uint256 communityRate; // 0% of pre-orders, 2.5% of launch/expansions, 2.5% of second-hand


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
            (bool sent, ) = payable(localSteez.creator).call{value: creatorFee}("");
            require(sent, "Failed to send Ether");

            // Pay the steeloFee to the platform
            (sent, ) = payable(owner()).call{value: steeloFee}("");
            require(sent, "Failed to send Ether");

            // Distribute the community royalty among investors
            for (uint256 i = 0; i < localSteez.investors.length; i++) {
                STEEZFacet.Investor storage localInvestor = localSteez.investors[i];
                uint256 shareholdingPercentage = (localInvestor.balance * 100) / localSteez.totalSupply;
                uint256 localRoyalty = (communityFee * shareholdingPercentage) / 100;

                // Update the total royalties and individual investor's royalties
                localSteez.royalties.totalRoyalties += localRoyalty;
                localSteez.royalties.royaltyAmounts[localInvestor.profileId] += localRoyalty;

                // Add the royalty payment to the investor's list of payments
                localSteez.royalties.royaltyPayments[localInvestor.profileId].push(localRoyalty);

                // Transfer the royalty to the investor immediately
                payable(localInvestor.profileId).transfer(localRoyalty);
            }

            // Ensure royalties are distributed correctly
            uint256 fromBalance = localSteez.balance;
            require(fromBalance >= amount, "Royalties: Insufficient balance");
            uint256 sellerFee = (from != owner()) ? (amount * ds.SECOND_HAND_SELLER_RATE)/1000 : 0;
            require(amount - totalRoyalty >= sellerFee, "Royalties: Insufficient amount for seller");

            // Pay the seller royalty (only for second-hand sales)
            if (from != owner()) {
                payable(from).transfer(sellerFee);
            }

            emit RoyaltiesDistributed(from, to, creatorId, amount, creatorFee, steeloFee, communityFee, data);
        }

        function viewRoyalties(address user, uint256 creatorId) public view returns (uint256 userShare, uint256 userRoyalty) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            STEEZFacet.Steez memory localSteez = STEEZFacet(ds.steezFacetAddress).steez(creatorId);

            if (localSteez.totalSupply == 0 || localSteez.balance == 0) {
                return (0, 0);
            }

            // Calculate user's share of the royalty
            userShare = (localSteez.royalties.totalRoyalties * localSteez.balance) / localSteez.totalSupply;

            // Calculate user's total royalty
            uint256 userSharePercentage = (localSteez.balance * 10000) / localSteez.totalSupply;
            userRoyalty = (localSteez.royalties.royaltyAmounts[user] * userSharePercentage)/10000;

            if (user == localSteez.creator) {
                userRoyalty = userRoyalty + localSteez.royalties.creatorRoyalty;
            } else if (user == ds.steezFacetAddress) { // Assuming ds.steezFacetAddress is the address of steelo
                userRoyalty = userRoyalty + localSteez.royalties.steeloRoyalty;
            } else if (localSteez.royalties.royaltyAmounts[user] > 0) { // Assuming the user is an investor if they have any royalty amounts
                userRoyalty = userRoyalty + localSteez.royalties.investorRoyalty;
            } else {
                userRoyalty = 0; // If the user is not related to the STEEZ, their royalty is 0
            }

            userRoyalty = userRoyalty + localSteez.royalties.unclaimedRoyalties;

            return (userShare, userRoyalty);
        }
}