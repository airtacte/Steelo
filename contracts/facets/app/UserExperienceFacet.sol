// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";

contract UserExperienceFacet {
    address userExperienceFacetAddress;
    function initialize() external {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        userExperienceFacetAddress = ds.userExperienceFacetAddress;
        ds.contractOwner = msg.sender;
    }
}