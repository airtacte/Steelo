// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./libraries/LibDiamond.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccessControlFacet is AccessControl {
    bytes32 public constant UPGRADE_ROLE = keccak256("UPGRADE_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(UPGRADE_ROLE, msg.sender);
    }

    function grantUpgradeRole(address account) external {
        grantRole(UPGRADE_ROLE, account);
    }

    function upgradeDiamond(address newImplementation) external {
        require(hasRole(UPGRADE_ROLE, msg.sender), "Must have upgrade role");
        // Implement upgrade logic
    }
}
