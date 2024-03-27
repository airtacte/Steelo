// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "./LibDiamond.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract SafeTemplate is OwnableUpgradeable {
    address safeTemplateAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    address[] public owners;
    uint256 public threshold;

    function setup(
        address[] memory _owners,
        uint256 _threshold,
        address to,
        bytes memory data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        safeTemplateAddress = ds.safeTemplateAddress;
        require(
            _owners.length >= _threshold,
            "Threshold cannot be higher than the number of owners"
        );
        owners = _owners;
        threshold = _threshold;
    }

    function isOwner(address owner) public view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == owner) {
                return true;
            }
        }
        return false;
    }

    // Additional functions for managing owners, executing transactions, etc.
}
