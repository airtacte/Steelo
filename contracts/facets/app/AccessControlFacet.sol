// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {IDiamondCut} from "../../interfaces/IDiamondCut.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

/**
 * @title Steelo AccessControl Facet
 * This contract manages roles and permissions within the Steelo ecosystem,
 * structured around the Diamond Standard for modular smart contracts.
 */
contract AccessControlFacet is
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
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

    // Event to be emitted when an upgrade is performed
    event DiamondUpgraded(
        address indexed upgradedBy,
        IDiamondCut.FacetCut[] cuts
    );
    event RoleUpdated(
        bytes32 indexed role,
        address indexed profileId,
        bool isGranted
    );

    function initialize(
        address _accessControlFacetAddress
    ) external onlyRole(EXECUTIVE_ROLE) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        accessControlFacetAddress = ds.accessControlFacetAddress;

        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        PausableUpgradeable.__Pausable_init();
        AccessControlUpgradeable.__AccessControl_init();

        // Assign the initial deployer the executive role
        _grantRole(EXECUTIVE_ROLE, msg.sender);

        // Steelo Labs Ltd roles
        _setRoleAdmin(ADMIN_ROLE, EXECUTIVE_ROLE);
        _setRoleAdmin(EMPLOYEE_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TESTER_ROLE, EMPLOYEE_ROLE);

        // Steelo roles
        _setRoleAdmin(STAKER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE, STAKER_ROLE);
        _setRoleAdmin(VISITOR_ROLE, USER_ROLE);

        // Steez roles
        _setRoleAdmin(CREATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TEAM_ROLE, CREATOR_ROLE);
        _setRoleAdmin(COLLABORATOR_ROLE, TEAM_ROLE);

        _setRoleAdmin(MODERATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(INVESTOR_ROLE, MODERATOR_ROLE);
        _setRoleAdmin(SUBSCRIBER_ROLE, INVESTOR_ROLE);
    }

    function assignVisitorRole() external {
        _grantRole(VISITOR_ROLE, msg.sender);
    }

    function _grantRole(
        bytes32 role,
        address walletAddress
    ) internal override onlyRole(role) returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(
            walletAddress != address(0),
            "AccessControl: walletAddress is zero address"
        );
        require(
            !hasRole(role, walletAddress),
            "AccessControl: walletAddress already has role"
        );
        super._grantRole(role, walletAddress);
        ds.roles[role].members[walletAddress] = true;
        emit RoleGranted(role, walletAddress, msg.sender);
        return true;
    }

    function _revokeRole(
        bytes32 role,
        address walletAddress
    ) internal override onlyRole(role) returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(
            hasRole(role, walletAddress),
            "AccessControl: walletAddress does not have role"
        );
        super._revokeRole(role, walletAddress);
        // Custom logic after revoking role
        return true;
    }

    // Function to update role from visitor to user after KYC approval

    // Function to update the staker role dynamically based on token holdings or other conditions
    function updateStakerRole(
        address walletAddress
    ) external onlyRole(ADMIN_ROLE) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(
            hasRole(EXECUTIVE_ROLE, msg.sender),
            "AccessControlFacet: Must have executive role to update roles"
        );

        // Check if user is a staker
        uint256 steeloBalance = ds.steelo.balanceOf(walletAddress);
        if (steeloBalance > 0 || ds.stakes[walletAddress] > 0) {
            grantRole(STAKER_ROLE, walletAddress);
            emit RoleUpdated(STAKER_ROLE, walletAddress, true);
        } else {
            revokeRole(STAKER_ROLE, walletAddress);
            emit RoleUpdated(STAKER_ROLE, walletAddress, false);
        }
    }

    // Function to update the investor role dynamically based on token holdings or other conditions
    function updateInvestorRole(
        address walletAddress,
        uint256 steezId
    ) external onlyRole(ADMIN_ROLE) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(
            hasRole(EXECUTIVE_ROLE, msg.sender),
            "AccessControlFacet: Must have executive role to update roles"
        );

        // Check if user is an investor in any creator or has steez token
        bool isInvestor = false;
        for (uint i = 0; i < ds.steez[steezId].investors.length; i++) {
            if (ds.steez[steezId].investors[i].walletAddress == walletAddress) {
                isInvestor = true;
                break;
            }
        }

        if (isInvestor) {
            grantRole(INVESTOR_ROLE, walletAddress);
            emit RoleUpdated(INVESTOR_ROLE, walletAddress, true);
        } else {
            revokeRole(INVESTOR_ROLE, walletAddress);
            emit RoleUpdated(INVESTOR_ROLE, walletAddress, false);
        }
    }

    function upgradeDiamond(
        IDiamondCut.FacetCut[] memory cuts
    ) external onlyRole(ADMIN_ROLE) {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Must have upgrade role to upgrade"
        );
        require(cuts.length > 0, "Must provide at least one cut to upgrade");

        // Perform the upgrade
        LibDiamond.diamondCut(cuts, address(0), new bytes(0));

        // Emit the DiamondUpgraded event
        emit DiamondUpgraded(msg.sender, cuts);
    }
}
