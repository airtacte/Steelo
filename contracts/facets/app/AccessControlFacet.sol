// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { IDiamondCut } from "../../interfaces/IDiamondCut.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title Steelo AccessControl Facet
 * This contract manages roles and permissions within the Steelo ecosystem,
 * structured around the Diamond Standard for modular smart contracts.
 */
contract AccessControlFacet is AccessControlUpgradeable {
    address accessControlFacetAddress;
    using EnumerableSet for EnumerableSet.AddressSet;

    // Define internal roles with unique bytes32 identifiers
    bytes32 public constant EXECUTIVE_ROLE = keccak256("EXECUTIVE_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE")
    bytes32 public constant EMPLOYEE_ROLE = keccak256("EMPLOYEE_ROLE");
    bytes32 public constant TESTER_ROLE = keccak256("TESTER_ROLE");

    // Stakeholders in the Steelo lifecycle
    bytes32 public constant STAKER_ROLE = keccak256("STAKER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant VISITOR_ROLE = keccak256("VISITOR_ROLE");

    // Stakeholders in the Steez lifecycle
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    bytes32 public constant TEAM_ROLE = keccak256("TEAM_ROLE");
    bytes32 public constant COLLABORATOR_ROLE = keccak256("COLLABORATOR_ROLE");
    bytes32 public constant INVESTOR_ROLE = keccak256("INVESTOR_ROLE");
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    /*
    modifier onlyAdmin() {require(admins[msg.sender], "Only Admin can call this function"); _;}
    modifier onlyCreator() {require(creators[msg.sender] && !admins[msg.sender], "CreatorToken: Only Creators can call this function"); _;}
    modifier onlyOwner() {require(!creators[msg.sender] && !admins[msg.sender] && investors[msg.sender], "CreatorToken: Only investors can call this function"); _;}
    modifier onlyUser() {require(users[msg.sender], "Only User can call this function"); _;}
    modifier onlyCreatorOrOwner() {require(investors[msg.sender] || creators[msg.sender], "CreatorToken: Only Creators or investors can call this function"); _;}
    */

    // System Roles allow users to upgrade to either (or both) STEELO_ROLE or STEEZ_ROLE
    /* Tier 5 */ mapping (address => bool) private admins; // SYSTEM_ROLE
    /* Tier 4 */ mapping (address => bool) private stakers; // STEELO_ROLE
    /* Tier 3 */ mapping (address => bool) private creators; // STEEZ_ROLE
    /* Tier 2 */ mapping (address => bool) private investors; // STEEZ_ROLE
    /* Tier 1 */ mapping (address => bool) private subscribers; // STEEZ_ROLE
    /* Tier 0 */ mapping (address => bool) private users; // USER_ROLE
    /* Tier -1 */ mapping (address => bool) private unverifiedUser; // DEFAULT_ROLE, pre-KYC

    // Event to be emitted when an upgrade is performed
    event DiamondUpgraded(address indexed upgradedBy, IDiamondCut.FacetCut[] cuts);
    
    function initialize(address _steeloFacet, address _steezFacet, address _accessControlFacetAddress) external {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        accessControlFacetAddress = ds.accessControlFacetAddress;

        _setRoleAdmin(ADMIN_ROLE, EXECUTIVE_ROLE);
        _setRoleAdmin(EMPLOYEE_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TESTER_ROLE, ADMIN_ROLE);

        // Similarly, set up the role hierarchy for Steelo lifecycles
        _setRoleAdmin(STAKER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE, EMPLOYEE_ROLE);
        _setRoleAdmin(VISITOR_ROLE, ""); // assigned automatically to users with verified wallet

        // Similarly, set up the role hierarchy for Steez lifecycles
        _setRoleAdmin(CREATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TEAM_ROLE, CREATOR_ROLE);
        _setRoleAdmin(COLLABORATOR_ROLE, CREATOR_ROLE);
        _setRoleAdmin(INVESTOR_ROLE, EMPLOYEE_ROLE);
        _setRoleAdmin(SUPPORTER_ROLE, EMPLOYEE_ROLE);

        // Initial role assignments
        _grantRole(EXECUTIVE_ROLE, msg.sender); // Assign the deployer the EXECUTIVE role
    }

    // System Roles include: Admin, Staker => Voter, Creator => Company, Investor, Subscriber, User
    function grantAdminRole(address account) external {
        grantRole(DEFAULT_ADMIN_ROLE, account);
        admins[account] = true;
    }

    function grantStakerRole(address account) external {
        grantRole(DEFAULT_ADMIN_ROLE, account);
        stakers[account] = true;
    }

    function grantCreatorRole(address account) external {
        grantRole(STEELO_ROLE, account);
        creators[account] = true;
    }

    function grantInvestorRole(address account) external {
        grantRole(STEEZ_ROLE, account);
        investors[account] = true;
    }

    function grantSubscriberRole(address account) external {
        grantRole(STEEZ_ROLE, account);
        subscribers[account] = true;
    }

    function grantUser(address account) external {
        users[account] = true;
    }

    function grantUpgradeRole(address account) external {
        grantRole(UPGRADE_ROLE, account);
    }

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
        uint256 steeloBalance = steeloFacet.balanceOf(account);
        uint256 steezBalance = steezFacet.balanceOf(account);

        if (steeloBalance > 0) {
            grantRole(STEELO_ROLE, account);
        }

        if (steezBalance > 0) {
            grantRole(STEEZ_ROLE, account);
        }
    }
}