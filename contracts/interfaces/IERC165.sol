// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @dev Interface of the ERC165 standard as defined in the EIP.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding EIP section to learn more about
     * how these IDs are created.
     *
     * This function call must use less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
        return interfaceId == type(IERC165).interfaceId || super.supportsInterface(interfaceId);
}