// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { STEEZFacet } from "../steez/STEEZFacet.sol";

contract SnapshotFacet {
    STEEZFacet steezFacet;
    
    uint256 private _snapshotCounter;
    uint256 private snapshotCounter;
    uint256 private _lastSnapshotTimestamp;

    mapping(uint256 => mapping(uint256 => uint256)) private _snapshotBalances;
    mapping(uint256 => uint256) private _lastSnapshot;
    mapping(uint256 => mapping(address => Snapshot[])) _holderSnapshots;
    mapping(uint256 => Snapshot[]) _totalUndistributedSnapshots;

    struct Snapshot {
        uint256 id;
        uint256 timestamp;
        uint256 value;
        mapping(address => uint256) balances;
    }

        function initialize() public {
            _takeSnapshot();
        }

        modifier dailySnapshot() {
            if (block.timestamp >= _lastSnapshotTimestamp + 1 days) {
                _takeSnapshot(); 
                _lastSnapshotTimestamp = block.timestamp;
            } 
            _;
        }

        // Increment the snapshot counter to create a new snapshot
        function _incrementSnapshot() internal returns (uint256) {
            return ++snapshotCounter;
        }

        // Record the balance for an address at the current snapshot
        function snapshotBalances(address account, uint256 balance) internal {
            uint256 currentId = _incrementSnapshot();
            _snapshotBalances[currentId][account] = balance;
        }

        function takeSnapshot() external {
            _takeSnapshot();
        }

        // Define the _takeSnapshot function
        function _takeSnapshot() internal {
            // Implementation of the function
        }

      function createSnapshot(uint256 creatorId) internal {
        uint256 blockNumber = block.number;

        // Iterate through the holders and create a snapshot for each one
        Steez parent = Steez(steezFacet.steez(creatorId));
        uint256 totalSupply = parent.totalSupply;

        for (uint256 i = 0; i < totalSupply; i++) {
            address holder = parent.ownerOf(i);
            uint256 holderBalance = parent.balance;
            _holderSnapshots[creatorId][holder].push(Snapshot(blockNumber, holderBalance));
        }
    }

    function _findSnapshotIndex(uint256 creatorId, address account) private view returns (uint256) {
        Snapshot[] storage snapshots = _holderSnapshots[creatorId][account];
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