// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import { STEELOFacet } from "../steelo/STEELOFacet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakingFacet is AccessControlFacet {
    address stakingFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;
    using SafeERC20 for IERC20;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}


    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 rewardAmount);

    function initialize(address _steeloFacet) public onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        stakingFacetAddress = ds.stakingFacetAddress;
    }

    function stake(uint256 _amount) external onlyRole(accessControl.USER_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        STEELOFacet steeloFacet = STEELOFacet(ds.steeloFacetAddress);

        require(_amount > 0, "Amount must be greater than 0");
        ds.stakes[msg.sender] += _amount;
        if (!ds.isStakeholder[msg.sender]) {
            ds.stakeholders.push(msg.sender);
            ds.isStakeholder[msg.sender] = true;
        }
        steeloFacet.safeTransferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external onlyRole(accessControl.STAKER_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        STEELOFacet steeloFacet = STEELOFacet(ds.steeloFacetAddress);

        require(_amount > 0, "Amount must be greater than 0");
        require(ds.stakes[msg.sender] >= _amount, "Not enough stake");
        ds.stakes[msg.sender] -= _amount;
        if (ds.stakes[msg.sender] == 0) {
            for (uint i = 0; i < ds.stakeholders.length; i++) {
                if (ds.stakeholders[i] == msg.sender) {
                    ds.stakeholders[i] = ds.stakeholders[ds.stakeholders.length - 1];
                    ds.stakeholders.pop();
                    ds.isStakeholder[msg.sender] = false;
                    break;
                }
            }
        }
        steeloFacet.safeTransfer(msg.sender, _amount);

        emit Unstaked(msg.sender, _amount);
    }
    
    // Placeholder for actual reward calculation logic
    function calculateReward(address stakeholder) internal view onlyRole(accessControl.STAKER_ROLE()) returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.totalStakingPool = getTotalStakingPool(); // This would sum all staked amounts
        uint256 stakeholderAmount = ds.stakes[stakeholder];
        ds.stakeDuration = ds.stakeDuration[stakeholder];

        if(ds.totalStakingPool == 0) return 0; // Prevent division by zero

        // Calculate the proportion of the total staked amount that the stakeholder owns
        uint256 stakeholderShare = (stakeholderAmount * ds.totalRewardPool) / ds.totalStakingPool;

        // Define yield rates based on staking duration as specified
        uint256 yieldRate;
        if (ds.stakeDuration >= 180 days) { // 6-Month Duration
            yieldRate = 79; // Representing 7.9%
        } else if (ds.stakeDuration >= 90 days) { // 3-Month Duration
            yieldRate = 49; // Representing 4.9%
        } else if (ds.stakeDuration >= 30 days) { // 1-Month Duration
            yieldRate = 29; // Representing 2.9%
        } else {
            yieldRate = 0; // No rewards for staking less than the minimum duration
        }
        // Calculate reward based on stakeholder's share and yield rate
        uint256 reward = (stakeholderShare * yieldRate) / 1000; // Dividing by 1000 to adjust for percentage representation

        return reward;
    }
    
    function distributeRewards() external onlyRole(accessControl.STAKER_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        STEELOFacet steeloFacet = STEELOFacet(ds.steeloFacetAddress);

        uint256 totalStaked = getTotalStakingPool();
        require(totalStaked > 0, "No stakes to distribute rewards to");
        require(ds.totalRewardPool > 0, "No rewards available for distribution");

        for (uint i = 0; i < ds.stakeholders.length; i++) {
            address stakeholder = ds.stakeholders[i];
            uint256 rewardAmount = calculateReward(stakeholder);
            if(rewardAmount > 0) {
                // Transfer reward to stakeholder from the facet contract
                steeloFacet.safeTransfer(stakeholder, rewardAmount);
                emit RewardPaid(stakeholder, rewardAmount);
                // Optionally, deduct the rewarded amount from the total reward pool
                ds.totalRewardPool -= rewardAmount;
            }
        }
    }

    // Helper function to get total staked amount
    function getTotalStakingPool() internal view returns (uint256 totalStaked) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        for (uint i = 0; i < ds.stakeholders.length; i++) {
            totalStaked += ds.stakes[ds.stakeholders[i]];
        }
        return totalStaked;
    }

    function stakeholderStatus(address _user) public view onlyRole(accessControl.STAKER_ROLE()) returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.isStakeholder[_user];
    }

    function stakeAmount(address _user) external view onlyRole(accessControl.STAKER_ROLE()) returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.stakes[_user];
    }
}