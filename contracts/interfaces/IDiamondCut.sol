// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IDiamondCut {
    // Struct for diamond cuts
    struct FacetCut {
        address facetAddress;
        Action action;
        bytes4[] functionSelectors;
    }

    enum Action { Add, Replace, Remove }

    // Adds, replaces, or removes functions
    // _facetCuts - An array of structs that contain a facet address and function selectors.
    // _init - An address of a contract or facet to call `init.functionSelectors.selector` 
    //         and pass `_calldata` to.
    // _calldata - Data to pass to `_init` address.
    function diamondCut(FacetCut[] calldata _facetCuts, address _init, bytes calldata _calldata) external;
    
    event DiamondCut(FacetCut[] _facetCuts, address _init, bytes _calldata);
}