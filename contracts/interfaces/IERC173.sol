// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @dev Interface of the ERC173 standard as defined in the EIP.
 */
interface IERC173 {
    /**
     * @dev Emitted when ownership of the contract is transferred.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address);

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external;
}