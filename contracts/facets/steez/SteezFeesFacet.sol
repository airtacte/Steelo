// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity 0.8.20;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract SteezFeesFacet is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    struct Royalties {
        address recipient;
        uint256 value;
    }

    struct RoyaltyInfo {
        address creator;
        address investor;
        uint256 share;
        uint256 value;
    }

    event RoyaltyPaid(uint256 indexed tokenId, address indexed recipient, uint256 amount);
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event DistributionPolicySet(uint256 tokenId, address recipient, uint256 share);

    mapping(uint256 => mapping(address => uint256)) public undistributedRoyalties;
    mapping(uint256 => uint256[]) public communitySplits;
    mapping(uint256 => address[]) public tokenHolders;
    mapping(uint256 => mapping(address => uint256)) public balances;

    modifier payRoyaltiesOnTransfer(uint256 id, uint256 value, address from, address to) { _; payRoyalties(id, value, from, to) ;}
    modifier onlyAdmin() {require(ds.steezFacet.isAdmin(msg.sender), "Royalties: Caller is not an admin"); _;}

    function initialize(address owner) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        transferOwnership(owner);
    }

        function setCommunitySplit(uint256 tokenId, uint256[] memory splits) external onlyOwner {
            // Ensure the sum of splits is 100
            uint256 total = 0;
            for (uint256 i = 0; i < splits.length; i++) {
                total += splits[i];
            }
            require(total == 100, "Total split must be 100");

            // Store the splits
            communitySplits[tokenId] = splits;
        }

        function payRoyalties(uint256 tokenId, uint256 amount, address from, address to, bytes memory data) external payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(tokenId > 0, "Royalties: Invalid token ID");
            require(amount > 0, "CreatorToken: Transfer amount must be greater than zero");
            require(msg.value >= amount, "Royalties: Insufficient payment");
            require(msg.sender == owner(), "Royalties: Caller is not the owner");

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
            uint256 creatorFee = amount.mul(creatorRate).div(100);
            uint256 steeloFee = amount.mul(steeloRate).div(100);
            uint256 communityFee = amount.mul(communityRate).div(100);
            uint256 totalRoyalty = creatorFee.add(steeloFee).add(communityFee);
            require(totalRoyalty <= amount, "Royalties: Royalty exceeds transfer amount");

            // Pay the creator royalty
            payable(from).transfer(creatorFee);
            payable(owner()).transfer(steeloFee);

            // Distribute the community royalty among the token holders
            for (uint256 i = 0; i < holders.length; i++) {
                uint256 balance = ds.balances[tokenId][holders[i]];
                uint256 share = communityFee.mul(balance).div(totalSupply);
                payable(holders[i]).transfer(share);
            }

            // Ensure royalties are distributed correctly
            uint256 fromBalance = ds.balances[tokenId][from];
            require(fromBalance >= amount, "Royalties: Insufficient balance");
            uint256 fromBalanceAfterTransfer = fromBalance.sub(amount);
            uint256 undistributedRoyalties = ds.undistributedRoyalties[tokenId][address(this)].add(communityFee);
            require(fromBalanceAfterTransfer >= undistributedRoyalties, "Royalties: Undistributed royalties not accounted for");
            require(amount.sub(creatorFee).sub(steeloFee).sub(communityFee) > 0, "Royalties: Insufficient amount for seller");

            // Pay the seller royalty (only for second-hand sales)
            if (from != owner()) {
                uint256 sellerFee = amount.mul(ds.SECOND_HAND_SELLER_RATE).div(1000);
                payable(from).transfer(sellerFee);
            }

            // Update balances in diamond storage
            ds.balances[tokenId][from] -= amount;
            ds.balances[tokenId][to] += amount;

            // Update creator and contract balances for royalties
            ds.balances[tokenId][_creator[tokenId]] += creatorFee;
            ds.balances[tokenId][address(this)] += steeloFee;

            // Update undistributed community royalties
            ds.undistributedRoyalties[tokenId][address(this)] += communityFee;

            emit RoyaltyDistributed(from, to, tokenId, amount, creatorFee, steeloFee, communityFee, data);
        }

        function claimRoyalty(uint256 tokenId) external nonReentrant {
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

        function viewRoyalties(address user, uint256 tokenId) public view returns (uint256 userShare, uint256 userRoyalty) {
            uint256 totalSupply = _totalSupply[tokenId];
            uint256 royalty = _royalty[tokenId].royalty;
            uint256 balance = balanceOf(user, tokenId);
            uint256 undistributedRoyalty = _undistributedRoyalties[tokenId][user];

            if (totalSupply == 0 || balance == 0) {
                return (0, 0);
            }

            // Calculate user's share of the royalty
            userShare = royalty.mul(balance).div(totalSupply);

            // Calculate user's total royalty
            uint256 userSharePercentage = balance.mul(10000).div(totalSupply);
            userRoyalty = _royalty[tokenId].creatorRoyalty.mul(userSharePercentage).div(10000);

            if (user == _creator[tokenId]) {
                userRoyalty = userRoyalty.add(_royalty[tokenId].creatorRoyalty);
            } else {
                userRoyalty = userRoyalty.add(_royalty[tokenId].steeloRoyalty);
            }

            userRoyalty = userRoyalty.add(undistributedRoyalty);

            return (userShare, userRoyalty);
        }

        // Batch updating royalties
        function updateRoyaltyRates(uint256[] calldata tokenIds, RoyaltyInfo[] calldata newRoyalties) external {
            require(tokenIds.length == newRoyalties.length, "Mismatched arrays");
            LibDiamond.enforceIsContractOwner();
            for(uint i = 0; i < tokenIds.length; i++) {
                royaltyInfo[tokenIds[i]] = newRoyalties[i];
            }
        }

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