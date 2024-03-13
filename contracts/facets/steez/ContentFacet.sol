// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ContentFacet is Initializable {
    address contentFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}

    modifier onlyExecutive() {
        require(accessControl.hasRole(accessControl.EXECUTIVE_ROLE(), msg.sender), "AccessControl: caller is not an executive");
        _;
    }

    function initialize() external onlyExecutive initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        contentFacetAddress = ds.contentFacetAddress;
    }

        // Example: Function to create a new content item
        function createContentItem(string calldata _title, string calldata _description, string calldata _contentURI) external {

        }

}