// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { IDiamondCut } from "../../interfaces/IDiamondCut.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * @title Steelo AccessControl Facet
 * This contract manages roles and permissions within the Steelo ecosystem,
 * structured around the Diamond Standard for modular smart contracts.
 */
contract AccessControlFacet is AccessControlEnumerableUpgradeable, ReentrancyGuardUpgradeable  {
    address accessControlFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;
    using EnumerableSet for EnumerableSet.AddressSet;

    modifier onlyExecutive() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.EXECUTIVE_ROLE, msg.sender), "AccessControl: caller is not an executive");
        _;
    }

    modifier onlyAdmin() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.ADMIN_ROLE, msg.sender), "AccessControl: caller is not an admin");
        _;
    }

    modifier onlyEmployee() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.EMPLOYEE_ROLE, msg.sender), "AccessControl: caller is not an employee");
        _;
    }

    modifier onlyTester() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.TESTER_ROLE, msg.sender), "AccessControl: caller is not a tester");
        _;
    }

    modifier onlyStaker() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.STAKER_ROLE, msg.sender), "AccessControl: caller is not a staker");
        _;
    }

    modifier onlyUser() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.USER_ROLE, msg.sender), "AccessControl: caller is not a user");
        _;
    }

    modifier onlyVisitor() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.VISITOR_ROLE, msg.sender), "AccessControl: caller is not a visitor");
        _;
    }

    modifier onlyCreator() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.CREATOR_ROLE, msg.sender), "AccessControl: caller is not a creator");
        _;
    }

    modifier onlyTeam() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.TEAM_ROLE, msg.sender), "AccessControl: caller is not a team member");
        _;
    }

    modifier onlyCollaborator() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.COLLABORATOR_ROLE, msg.sender), "AccessControl: caller is not a collaborator");
        _;
    }

    modifier onlyInvestor() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.INVESTOR_ROLE, msg.sender), "AccessControl: caller is not an investor");
        _;
    }

    modifier onlyModerator() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.MODERATOR_ROLE, msg.sender), "AccessControl: caller is not a moderator");
        _;
    }

    modifier onlySubscriber() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.SUBSCRIBER_ROLE, msg.sender), "AccessControl: caller is not a subscriber");
        _;
    }

    // Event to be emitted when an upgrade is performed
    event DiamondUpgraded(address indexed upgradedBy, IDiamondCut.FacetCut[] cuts);
    event RoleUpdated(bytes32 indexed role, address indexed account, bool isGranted);

    function initialize(address _steeloFacet, address _steezFacet, address _accessControlFacetAddress) external {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        accessControlFacetAddress = ds.accessControlFacetAddress;

        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();

        _setRoleAdmin(ds.constants.ADMIN_ROLE, ds.constants.EXECUTIVE_ROLE);
        _setRoleAdmin(ds.constants.EMPLOYEE_ROLE, ds.constants.ADMIN_ROLE);
        _setRoleAdmin(ds.constants.TESTER_ROLE, ADMIN_ROLE);

        // Similarly, set up the role hierarchy for Steelo lifecycles
        _setRoleAdmin(ds.constants.STAKER_ROLE, ds.constants.ADMIN_ROLE);
        _setRoleAdmin(ds.constants.USER_ROLE, ds.constants.EMPLOYEE_ROLE);
        _setRoleAdmin(ds.constants.VISITOR_ROLE, ""); // assigned automatically to users with verified wallet

        // Similarly, set up the role hierarchy for Steez lifecycles
        _setRoleAdmin(ds.constants.CREATOR_ROLE, ds.constants.ADMIN_ROLE);
        _setRoleAdmin(ds.constants.TEAM_ROLE, ds.constants.CREATOR_ROLE);
        _setRoleAdmin(ds.constants.MODERATOR_ROLE, ds.constants.CREATOR_ROLE);
        _setRoleAdmin(ds.constants.COLLABORATOR_ROLE, ds.constants.CREATOR_ROLE);
        _setRoleAdmin(ds.constants.INVESTOR_ROLE, ds.constants.CREATOR_ROLE);
        _setRoleAdmin(ds.constants.SUBSCRIBER_ROLE, ds.constants.CREATOR_ROLE);

        // Initial role assignments
        _grantRole(ds.constants.ds.constants.EXECUTIVE_ROLE, msg.sender); // Assign the deployer the EXECUTIVE role
    }

    // Override _grantRole and _revokeRole to integrate custom logic or restrictions
    function _grantRole(ds.constants.bytes32 role, address account) internal override {
        super._grantRole(ds.constants.role, account);
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(!hasRole(ds.constants.role, account), "AccessControl: account already has role");
        require(account != address(0), "AccessControl: account is zero address");

        ds.roles[role].members[account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    function _revokeRole(bytes32 role, address account) internal override {
        super._revokeRole(role, account);
        // Custom logic after revoking role
    }

    // Function to update the role dynamically based on token holdings or other conditions
    function updateRoleBasedOnConditions(address account) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.EXECUTIVE_ROLE, msg.sender), "AccessControlFacet: Must have executive role to update roles");

        // Check if user is a staker
        if (ds.stakes[account] > 0) {
            grantRole(ds.constants.STAKER_ROLE, account);
            emit RoleUpdated(ds.constants.STAKER_ROLE, account, true);
        } else {
            revokeRole(ds.constants.STAKER_ROLE, account);
            emit RoleUpdated(ds.constants.STAKER_ROLE, account, false);
        }

        // Check if user is an investor in any creator
        ds.isInvestor = false;
        for (uint i = 0; i < ds.investor.portfolio[account].length; i++) {
            if (ds.investor.portfolio[account][i].steez > 0) {
                ds.isInvestor = true;
                break;
            }
        }

        if (ds.isInvestor) {
            grantRole(ds.constants.INVESTOR_ROLE, account);
            emit RoleUpdated(ds.constants.INVESTOR_ROLE, account, true);
        } else {
            revokeRole(ds.constants.INVESTOR_ROLE, account);
            emit RoleUpdated(ds.constants.INVESTOR_ROLE, account, false);
        }
    }

    function grantExecutiveRole(address account) external onlyRole(EXECUTIVE_ROLE) {
        grantRole(ds.constants.EXECUTIVE_ROLE, account);
    }

    function grantAdminRole(address account) external onlyRole(ADMIN_ROLE) {
        grantRole(ds.constants.ADMIN_ROLE, account);
    }

    function grantEmployeeRole(address account) external onlyRole(EMPLOYEE_ROLE) {
        grantRole(ds.constants.EMPLOYEE_ROLE, account);
    }

    function grantTesterRole(address account) external onlyRole(TESTER_ROLE) {
        grantRole(ds.constants.TESTER_ROLE, account);
    }

    function grantStakerRole(address account) external onlyRole(STAKER_ROLE) {
        grantRole(ds.constants.STAKER_ROLE, account);
    }

    function grantUserRole(address account) external onlyRole(USER_ROLE) {
        grantRole(ds.constants.USER_ROLE, account);
    }

    function grantVisitorRole(address account) external onlyRole(VISITOR_ROLE) {
        grantRole(ds.constants.VISITOR_ROLE, account);
    }

    function grantCreatorRole(address account) external onlyRole(CREATOR_ROLE) {
        grantRole(ds.constants.CREATOR_ROLE, account);
    }

    function grantTeamRole(address account) external onlyRole(TEAM_ROLE) {
        grantRole(ds.constants.TEAM_ROLE, account);
    }

    function grantModeratorRole(address account) external onlyRole(MODERATOR_ROLE) {
        grantRole(ds.constants.MODERATOR_ROLE, account);
    }

    function grantCollaboratorRole(address account) external onlyRole(COLLABORATOR_ROLE) {
        grantRole(ds.constants.COLLABORATOR_ROLE, account);
    }

    function grantInvestorRole(address account) external onlyRole(INVESTOR_ROLE) {
        grantRole(ds.constants.INVESTOR_ROLE, account);
    }

    function grantSubscriberRole(address account) external onlyRole(SUBSCRIBER_ROLE) {
        grantRole(ds.constants.SUBSCRIBER_ROLE, account);
    }

    function upgradeDiamond(IDiamondCut.FacetCut[] memory cuts) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(hasRole(ds.constants.ADMIN_ROLE, msg.sender), "Must have upgrade role to upgrade");
        require(cuts.length > 0, "Must provide at least one cut to upgrade");

        // Perform the upgrade
        LibDiamond.diamondCut(cuts, address(0), new bytes(0));

        // Emit the DiamondUpgraded event
        emit DiamondUpgraded(msg.sender, cuts);
    }

    function grantRoleBasedOnTokenHolding(address account) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 steeloBalance = ds.balanceOf(account);
        uint256 steezBalance = ds.balanceOf(account);

        if (steeloBalance > 0) {
            grantRole(ds.constants.STAKER_ROLE, account);
        }

        if (steezBalance > 0) {
            grantRole(ds.constants.INVESTOR_ROLE, account);
        }
    }
}