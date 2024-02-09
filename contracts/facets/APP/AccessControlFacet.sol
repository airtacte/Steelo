// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./libraries/LibDiamond.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AccessControlFacet is AccessControl {
    bytes32 public constant UPGRADE_ROLE = keccak256("UPGRADE_ROLE");
    bytes32 public constant STEELO_ROLE = keccak256("STEELO_ROLE");
    bytes32 public constant STEEZ_ROLE = keccak256("STEEZ_ROLE");

    IERC20 public steeloToken;
    IERC20 public steezToken;

    constructor(address _steeloToken, address _steezToken) {
        steeloToken = IERC20(_steeloToken);
        steezToken = IERC20(_steezToken);

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(UPGRADE_ROLE, msg.sender);
    }

    function grantUpgradeRole(address account) external {
        grantRole(UPGRADE_ROLE, account);
    }

    // Event to be emitted when an upgrade is performed
    event DiamondUpgraded(address indexed upgradedBy, IDiamondCut.FacetCut[] cuts);

    function upgradeDiamond(IDiamondCut.FacetCut[] memory cuts) external {
        // Check that the caller has the upgrade role
        require(hasRole(UPGRADE_ROLE, msg.sender), "Must have upgrade role to upgrade");

        // Check that the cuts array is not empty
        require(cuts.length > 0, "Must provide at least one cut to upgrade");

        // Perform the upgrade
        LibDiamond.diamondCut(cuts, address(0), new bytes(0));

        // Emit the DiamondUpgraded event
        emit DiamondUpgraded(msg.sender, cuts);
    }

    function grantRoleBasedOnTokenHolding(address account) external {
        uint256 steeloBalance = steeloToken.balanceOf(account);
        uint256 steezBalance = steezToken.balanceOf(account);

        if (steeloBalance > 0) {
            grantRole(STEELO_ROLE, account);
        }

        if (steezBalance > 0) {
            grantRole(STEEZ_ROLE, account);
        }
    }
}