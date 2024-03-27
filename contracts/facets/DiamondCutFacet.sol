// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {AccessControlFacet} from "./app/AccessControlFacet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

contract DiamondCutFacet is
    IDiamondCut,
    AccessControlFacet,
    OwnableUpgradeable
{
    uint256 public constant facetVersion = 1;
    event FacetAdded(address indexed facetAddress, bytes4[] functionSelectors);

    AccessControlFacet accessControl; // Instance of the AccessControlFacet

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    function initialize()
        public
        onlyRole(accessControl.EXECUTIVE_ROLE())
        initializer
    {}

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override onlyRole(accessControl.EXECUTIVE_ROLE()) {
        // Validation should be part of the loop processing _diamondCut
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            require(
                _diamondCut[i].facetAddress != address(0),
                "Invalid address"
            );
            require(
                _diamondCut[i].functionSelectors.length > 0,
                "No selectors provided"
            );
            // Event emission can be inside loop after each FacetCut is processed
            emit FacetAdded(
                _diamondCut[i].facetAddress,
                _diamondCut[i].functionSelectors
            );
        }
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
}
