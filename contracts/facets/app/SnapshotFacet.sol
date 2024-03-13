// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "./AccessControlFacet.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SnapshotFacet is Initializable {
    address snapshotFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}

    uint256 private _snapshotCounter;
    uint256 private snapshotCounter;
    uint256 private _lastSnapshotTimestamp;

    mapping(uint256 => mapping(uint256 => uint256)) private _snapshotBalances;
    mapping(uint256 => uint256) private _lastSnapshot;
    mapping(uint256 => mapping(address => Snapshot[])) _holderSnapshots;
    mapping(uint256 => Snapshot[]) _totalUndistributedSnapshots;

    modifier dailySnapshot() {
        if (block.timestamp >= _lastSnapshotTimestamp + 1 days) {
            _takeSnapshot(); 
            _lastSnapshotTimestamp = block.timestamp;
        } 
        _;
    }

    modifier onlyExecutive() {
        require(accessControl.hasRole(accessControl.EXECUTIVE_ROLE(), msg.sender), "AccessControl: caller is not an executive");
        _;
    }

    function initialize() public onlyExecutive initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        snapshotFacetAddress = ds.snapshotFacetAddress;

        _takeSnapshot();
    }

    // Increment the snapshot counter to create a new snapshot
    function _incrementSnapshot() internal returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ++ds.snapshotCounter;
    }

    // Record the balance for an address at the current snapshot
    function snapshotBalances(uint256 profileId, uint256 balance) internal {
        uint256 currentId = _incrementSnapshot();
        _snapshotBalances[creatorId][profileId] = balance;
    }

    function takeSnapshot() external {
        _takeSnapshot();
    }

    // Function to take a snapshot of the current token balances
    function _takeSnapshot() internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 currentId = _incrementSnapshot();
        // Loop over all creator addresses
        for (uint256 j = 0; j < ds.creatorAddresses.length; j++) {
            address creatorAddress = ds.creatorAddresses[j];
            // Get the Steez instance associated with the current creator address
            // Loop over all investors of the current Steez instance
            for (uint256 i = 0; i < ds.steez.totalSupply; i++) {
                ds.snapshots[currentId].balances[i] = ds.steez.investors[i].balance;
            }
        }
        // Emitting an event could be considered here to log snapshot actions
    }

    function createSnapshot(uint256 creatorId) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 blockNumber = block.number;
        uint256 totalSupply = ds.steez.totalSupply;

        for (uint256 i = 0; i < totalSupply; i++) {
            address holder = ds.steez.ownerOf(i);
            uint256 holderBalance = ds.steez.balance;
            ds.snapshots[creatorId].balances[holder] = holderBalance;
        }
    }

    function _findSnapshotIndex(uint256 creatorId, address account) private view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 left = 0;
        uint256 right = ds.snapshots[creatorId].balances.length;

        while (left < right) {
            uint256 mid = left.add(right).div(2);
            if (ds.snapshots[mid].blockNumber <= block.number) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return left.sub(1);
    }
}