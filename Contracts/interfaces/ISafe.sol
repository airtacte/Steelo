// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ISafe {
    // Define the interface methods based on Safe{core} functionalities you plan to use
    function createSafe(address _owner) external returns (address safeAddress);
    function executeTransaction(
        address safeAddress,
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        bytes calldata signatures
    ) external payable returns (bool success);
    // Add more methods as required
}