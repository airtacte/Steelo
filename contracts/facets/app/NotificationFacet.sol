// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { LibDiamond } from "../libraries/LibDiamond.sol";

contract NotificationFacet {
    function initialize() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;
    }
}