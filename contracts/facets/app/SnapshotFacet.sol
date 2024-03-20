// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "./AccessControlFacet.sol";

contract SnapshotFacet is AccessControlFacet {
    address snapshotFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}

    modifier dailySnapshot(uint256 creatorId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (block.timestamp >= ds.lastSnapshotTimestamp + 1 days) {
            takeSnapshot(creatorId);
            ds.lastSnapshotTimestamp = block.timestamp;
        }
        _;
    }

    function initialize() public onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        snapshotFacetAddress = ds.snapshotFacetAddress;
    }

    // Increment the snapshot counter to create a new snapshot
    function _incrementSnapshot() internal returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ++ds.snapshotCounter;
    }

    // Record the balance for an address at the current snapshot
    function takeSnapshot(uint256 creatorId) public dailySnapshot(creatorId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 currentId = ds.snapshotCounter++;
        LibDiamond.Snapshot storage snapshot = ds.snapshots[currentId];
        snapshot.timestamp = block.timestamp;
        snapshot.value = ds.steez[creatorId].totalSupply;

        for (uint256 i = 0; i < ds.steez[creatorId].investors.length; i++) {
            address holder = ds.steez[creatorId].investors[i].walletAddress;
            uint256 steezId = ds.steez[creatorId].steezId; // Ensure steezId is correctly defined and accessible

            LibDiamond.Investor storage investor = ds.steez[creatorId].investors[i];
            uint256 holderBalance = investor.portfolio[steezId];

            snapshot.balances[holder][steezId] = holderBalance;
        }
    }

    // View the balance for an address at a given snapshot
    function findSteezSnapshotBalance(uint256 snapshotId, address walletAddress, uint256 steezId) external view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.snapshots[snapshotId].balances[walletAddress][steezId];
    }

    // View the balance for an address and a specific token at a given snapshot
    function findUserSnapshotBalance(uint256 snapshotId, address walletAddress, uint256 steezId) external view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.snapshots[snapshotId].balances[walletAddress][steezId];
    }
}