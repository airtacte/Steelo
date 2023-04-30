// SPDX-License-Identifier: MIT
// contracts/DiamondCutFacet.sol
pragma solidity ^0.8.19;

import "./interfaces/IERC2535.sol";
import "./SteeloToken.sol";

contract DiamondCutFacet is IERC2535 {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    
    function SteeloCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;
}