// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

contract Migrations {
    address public owner;

    // A function with the signature `last_completed_migration()`, returning a uint, is required.
    uint256 public last_completed_migration;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    constructor() {
        owner = msg.sender;
    }

    // A function with the signature `setCompleted(uint)` is required.
    function setCompleted(uint256 completed) external restricted {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) external restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}