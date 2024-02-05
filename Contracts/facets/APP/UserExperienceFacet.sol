// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./libraries/LibDiamond.sol";

contract UserExperienceFacet {
    function initialize() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;
    }
}