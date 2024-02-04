// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasOptimisationFacet {
    // Example: Bulk processing to minimise transaction costs
    function bulkProcessData(uint256[] calldata data) external {
        for (uint256 i = 0; i < data.length; i++) {
            // Process data in a gas-efficient manner
        }
    }
}
