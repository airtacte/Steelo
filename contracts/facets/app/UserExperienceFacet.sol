// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";

contract UserExperienceFacet {
    address userExperienceFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    function initialize() external {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        userExperienceFacetAddress = ds.userExperienceFacetAddress;
    }
}