// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity 0.8.20;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccessControlFacet is AccessControl {
    bytes32 public constant UPGRADE_ROLE = keccak256("UPGRADE_ROLE");
    bytes32 public constant STEELO_ROLE = keccak256("STEELO_ROLE");
    bytes32 public constant STEEZ_ROLE = keccak256("STEEZ_ROLE");

    IERC20 public steeloToken;
    IERC20 public steezToken;

    modifier onlyAdmin() {require(admins[msg.sender], "Only Admin can call this function"); _;}
    modifier onlyCreator() {require(creatorToIsAdmin[msg.sender] == false && msg.sender != creator, "CreatorToken: Only Creators can call this function"); _;}
    modifier onlyOwner() {require(creatorToIsAdmin[msg.sender] == false && msg.sender != creator && msg.sender != owner(), "CreatorToken: Only Owners can call this function"); _;}
    modifier onlyUser() {require(users[msg.sender], "Only User can call this function"); _;}
    modifier onlyCreatorOrOwner() {require(owners[msg.sender] || creators[msg.sender], "CreatorToken: Only Creators or Owners can call this function"); _;}

    mapping (address => bool) private admins;
    mapping (address => bool) private creators;
    mapping (address => bool) private owners; // to rename to investors
    mapping (address => bool) private users;

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