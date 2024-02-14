// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity 0.8.20;

import { LibDiamond } from "../../libraries/LibDiamond.sol";

contract SecurityComplianceFacet {
    function initialize() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;
    }
}