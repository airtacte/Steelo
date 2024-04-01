// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "../app/AccessControlFacet.sol";

contract ContentFacet is AccessControlFacet {
    address contentFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl;

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    function initialize()
        external
        onlyRole(accessControl.EXECUTIVE_ROLE())
        initializer
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        contentFacetAddress = ds.contentFacetAddress;
    }

    // Example: Function to create a new content item
    function createContentItem(
        string calldata title,
        string calldata _contentURI
    ) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        
    }


}
