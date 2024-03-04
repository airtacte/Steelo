// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IDiamondCut } from "../../interfaces/IDiamondCut.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract AccessControlFacet is AccessControlUpgradeable {
    address accessControlFacetAddress;
    bytes32 public constant UPGRADE_ROLE = keccak256("UPGRADE_ROLE");
    bytes32 public constant STEELO_ROLE = keccak256("STEELO_ROLE");
    bytes32 public constant STEEZ_ROLE = keccak256("STEEZ_ROLE");

    IERC20 public steeloFacet;
    IERC20 public steezFacet;

    modifier onlyAdmin() {require(admins[msg.sender], "Only Admin can call this function"); _;}
    modifier onlyCreator() {require(creators[msg.sender] && !admins[msg.sender], "CreatorToken: Only Creators can call this function"); _;}
    modifier onlyOwner() {require(!creators[msg.sender] && !admins[msg.sender] && investors[msg.sender], "CreatorToken: Only investors can call this function"); _;}
    modifier onlyUser() {require(users[msg.sender], "Only User can call this function"); _;}
    modifier onlyCreatorOrOwner() {require(investors[msg.sender] || creators[msg.sender], "CreatorToken: Only Creators or investors can call this function"); _;}

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
        steeloFacet = IERC20(_steeloFacet);
        steezFacet = IERC20(_steezFacet);

        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(UPGRADE_ROLE, msg.sender);
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