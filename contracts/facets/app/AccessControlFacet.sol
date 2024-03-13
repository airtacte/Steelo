// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { IDiamondCut } from "../../interfaces/IDiamondCut.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * @title Steelo AccessControl Facet
 * This contract manages roles and permissions within the Steelo ecosystem,
 * structured around the Diamond Standard for modular smart contracts.
 */
contract AccessControlFacet is AccessControlUpgradeable, ReentrancyGuardUpgradeable  {
    address accessControlFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    bytes32 public constant EXECUTIVE_ROLE = keccak256("EXECUTIVE_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant EMPLOYEE_ROLE = keccak256("EMPLOYEE_ROLE");
    bytes32 public constant TESTER_ROLE = keccak256("TESTER_ROLE");
    bytes32 public constant STAKER_ROLE = keccak256("STAKER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant VISITOR_ROLE = keccak256("VISITOR_ROLE");
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    bytes32 public constant TEAM_ROLE = keccak256("TEAM_ROLE");
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant COLLABORATOR_ROLE = keccak256("COLLABORATOR_ROLE");
    bytes32 public constant INVESTOR_ROLE = keccak256("INVESTOR_ROLE");
    bytes32 public constant SUBSCRIBER_ROLE = keccak256("SUBSCRIBER_ROLE");

    modifier onlyExecutive() {
        require(hasRole(EXECUTIVE_ROLE, msg.sender), "AccessControl: caller is not an executive");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "AccessControl: caller is not an admin");
        _;
    }

    modifier onlyEmployee() {
        require(hasRole(EMPLOYEE_ROLE, msg.sender), "AccessControl: caller is not an employee");
        _;
    }

    modifier onlyTester() {
        require(hasRole(TESTER_ROLE, msg.sender), "AccessControl: caller is not a tester");
        _;
    }

    modifier onlyStaker() {
        require(hasRole(STAKER_ROLE, msg.sender), "AccessControl: caller is not a staker");
        _;
    }

    modifier onlyUser() {
        require(hasRole(USER_ROLE, msg.sender), "AccessControl: caller is not a user");
        _;
    }

    modifier onlyVisitor() {
        require(hasRole(VISITOR_ROLE, msg.sender), "AccessControl: caller is not a visitor");
        _;
    }

    modifier onlyCreator() {
        require(hasRole(CREATOR_ROLE, msg.sender), "AccessControl: caller is not a creator");
        _;
    }

    modifier onlyTeam() {
        require(hasRole(TEAM_ROLE, msg.sender), "AccessControl: caller is not a team member");
        _;
    }

    modifier onlyCollaborator() {
        require(hasRole(COLLABORATOR_ROLE, msg.sender), "AccessControl: caller is not a collaborator");
        _;
    }

    modifier onlyInvestor() {
        require(hasRole(INVESTOR_ROLE, msg.sender), "AccessControl: caller is not an investor");
        _;
    }

    modifier onlyModerator() {
        require(hasRole(MODERATOR_ROLE, msg.sender), "AccessControl: caller is not a moderator");
        _;
    }

    modifier onlySubscriber() {
        require(hasRole(SUBSCRIBER_ROLE, msg.sender), "AccessControl: caller is not a subscriber");
        _;
    }

    // Event to be emitted when an upgrade is performed
    event DiamondUpgraded(address indexed upgradedBy, IDiamondCut.FacetCut[] cuts);
    event RoleUpdated(bytes32 indexed role, address indexed account, bool isGranted);

    function initialize(address _steeloFacet, address _steezFacet, address _accessControlFacetAddress) external onlyExecutive initializer {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        accessControlFacetAddress = ds.accessControlFacetAddress;

        __ReentrancyGuard_init();

        _setRoleAdmin(ADMIN_ROLE, EXECUTIVE_ROLE);
        _setRoleAdmin(EMPLOYEE_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TESTER_ROLE, ADMIN_ROLE);

        // Steelo lifecycles
        _setRoleAdmin(STAKER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE, EMPLOYEE_ROLE);
        _setRoleAdmin(VISITOR_ROLE, ""); // assigned automatically to users with verified wallet

        // Steez lifecycles
        _setRoleAdmin(CREATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TEAM_ROLE, CREATOR_ROLE);
        _setRoleAdmin(MODERATOR_ROLE, CREATOR_ROLE);
        _setRoleAdmin(COLLABORATOR_ROLE, CREATOR_ROLE);
        _setRoleAdmin(INVESTOR_ROLE, CREATOR_ROLE);
        _setRoleAdmin(SUBSCRIBER_ROLE, CREATOR_ROLE);

        // Initial role assignments
        _grantRole(EXECUTIVE_ROLE, msg.sender); // Assign the deployer the EXECUTIVE role
    }

    // Override _grantRole and _revokeRole to integrate custom logic or restrictions
    function _grantRole(bytes32 role, address account) internal override {
        super._grantRole(role, account);
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(!hasRole(role, account), "AccessControl: account already has role");
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
        require(hasRole(EXECUTIVE_ROLE, msg.sender), "AccessControlFacet: Must have executive role to update roles");

        // Check if user is a staker
        if (ds.stakes[account] > 0) {
            grantRole(STAKER_ROLE, account);
            emit RoleUpdated(STAKER_ROLE, account, true);
        } else {
            revokeRole(STAKER_ROLE, account);
            emit RoleUpdated(STAKER_ROLE, account, false);
        }

        // Check if user is an investor in any creator
        ds.investors.isInvestor = false;
        for (uint i = 0; i < ds.investor.portfolio[account].length; i++) {
            if (ds.investor.portfolio[account][i].steez > 0) {
                ds.isInvestor = true;
                break;
            }
        }

        if (ds.investors.isInvestor) {
            grantRole(INVESTOR_ROLE, account);
            emit RoleUpdated(INVESTOR_ROLE, account, true);
        } else {
            revokeRole(INVESTOR_ROLE, account);
            emit RoleUpdated(INVESTOR_ROLE, account, false);
        }
    }

    function grantExecutiveRole(address account) external onlyRole(EXECUTIVE_ROLE) {
        grantRole(EXECUTIVE_ROLE, account);
    }

    function grantAdminRole(address account) external onlyRole(ADMIN_ROLE) {
        grantRole(ADMIN_ROLE, account);
    }

    function grantEmployeeRole(address account) external onlyRole(EMPLOYEE_ROLE) {
        grantRole(EMPLOYEE_ROLE, account);
    }

    function grantTesterRole(address account) external onlyRole(TESTER_ROLE) {
        grantRole(TESTER_ROLE, account);
    }

    function grantStakerRole(address account) external onlyRole(STAKER_ROLE) {
        grantRole(STAKER_ROLE, account);
    }

    function grantUserRole(address account) external onlyRole(USER_ROLE) {
        grantRole(USER_ROLE, account);
    }

    function grantVisitorRole(address account) external onlyRole(VISITOR_ROLE) {
        grantRole(VISITOR_ROLE, account);
    }

    function grantCreatorRole(address account) external onlyRole(CREATOR_ROLE) {
        grantRole(CREATOR_ROLE, account);
    }

    function grantTeamRole(address account) external onlyRole(TEAM_ROLE) {
        grantRole(TEAM_ROLE, account);
    }

    function grantModeratorRole(address account) external onlyRole(MODERATOR_ROLE) {
        grantRole(MODERATOR_ROLE, account);
    }

    function grantCollaboratorRole(address account) external onlyRole(COLLABORATOR_ROLE) {
        grantRole(COLLABORATOR_ROLE, account);
    }

    function grantInvestorRole(address account) external onlyRole(INVESTOR_ROLE) {
        grantRole(INVESTOR_ROLE, account);
    }

    function grantSubscriberRole(address account) external onlyRole(SUBSCRIBER_ROLE) {
        grantRole(SUBSCRIBER_ROLE, account);
    }

    function upgradeDiamond(IDiamondCut.FacetCut[] memory cuts) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "Must have upgrade role to upgrade");
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
            grantRole(STAKER_ROLE, account);
        }

        if (steezBalance > 0) {
            grantRole(INVESTOR_ROLE, account);
        }
    }
}