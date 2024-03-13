// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { STEELOFacet } from "../steelo/STEELOFacet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract StakingFacet is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address stakingFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;
    using SafeERC20 for IERC20;

    modifier onlyStaker() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.contractOwner.hasRole(ds.constants.STAKER_ROLE, msg.sender), "SIPFacet: caller is not a staker");
        _;
    }

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 rewardAmount);

    // Storage
    mapping(address => bool) public isStakeholder;
    mapping(address => uint256) public stakeDuration;
    mapping(address => uint256) public totalRewardPool;
    mapping(address => uint256) public totalStakingPool;
    mapping(uint256 => bool) stakeholders;

    function initialize(address _steeloFacet) public initializer {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        stakingFacetAddress = ds.stakingFacetAddress;
        
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function stake(uint256 _amount) external nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        require(_amount > 0, "Amount must be greater than 0");
        ds.stakes[msg.sender] += _amount;
        if (!ds.isStakeholder[msg.sender]) {
            ds.stakeholders.push(msg.sender);
            ds.isStakeholder[msg.sender] = true;
        }
        steeloFacet.safeTransferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external onlyStaker nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

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
    function calculateReward(address stakeholder) internal view onlyStaker returns (uint256) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        totalStakingPool = getTotalStakingPool(); // This would sum all staked amounts
        uint256 stakeholderAmount = ds.stakes[stakeholder];
        stakeDuration = stakeDuration[stakeholder];

        if(totalStakingPool == 0) return 0; // Prevent division by zero

        // Calculate the proportion of the total staked amount that the stakeholder owns
        uint256 stakeholderShare = (stakeholderAmount * totalRewardPool) / totalStakingPool;

        // Define yield rates based on staking duration as specified
        uint256 yieldRate;
        if (stakeDuration >= 180 days) { // 6-Month Duration
            yieldRate = 79; // Representing 7.9%
        } else if (stakeDuration >= 90 days) { // 3-Month Duration
            yieldRate = 49; // Representing 4.9%
        } else if (stakeDuration >= 30 days) { // 1-Month Duration
            yieldRate = 29; // Representing 2.9%
        } else {
            yieldRate = 0; // No rewards for staking less than the minimum duration
        }
        // Calculate reward based on stakeholder's share and yield rate
        uint256 reward = (stakeholderShare * yieldRate) / 1000; // Dividing by 1000 to adjust for percentage representation

        return reward;
    }
    
    function distributeRewards() external onlyStaker nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        
        uint256 totalStaked = getTotalStakingPool();
        require(totalStaked > 0, "No stakes to distribute rewards to");
        require(totalRewardPool > 0, "No rewards available for distribution");

        for (uint i = 0; i < ds.stakeholders.length; i++) {
            address stakeholder = stakeholders[i];
            uint256 rewardAmount = calculateReward(stakeholder);
            if(rewardAmount > 0) {
                // Transfer reward to stakeholder from the facet contract
                steeloFacet.safeTransfer(stakeholder, rewardAmount);
                emit RewardPaid(stakeholder, rewardAmount);
                // Optionally, deduct the rewarded amount from the total reward pool
                totalRewardPool -= rewardAmount;
            }
        }
    }

    // Helper function to get total staked amount
    function getTotalStakingPool() internal view returns (uint256 totalStaked) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        for (uint i = 0; i < stakeholders.length; i++) {
            totalStaked += ds.stakes[stakeholders[i]];
        }
        return totalStaked;
    }

    function stakeholderStatus(address _user) public view onlyStaker returns (bool) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        return ds.isStakeholder[_user];
    }

    function stakeAmount(address _user) external view onlyStaker returns (uint256) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        return ds.stakes[_user];
    }
}