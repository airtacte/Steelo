// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity 0.8.20;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ISteeloFacet } from "../../interfaces/ISteeloFacet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract SteeloStakingFacet is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    ISteeloFacet public steeloFacet;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 rewardAmount);

    // Storage
    mapping(address => uint256) public stakes;
    mapping(address => bool) public isStakeholder;
    mapping(address => uint256) public stakeDuration;

    function initialize(address _steeloFacet) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.steeloFacet = IERC20Upgradeable(_steeloFacet);
    }

    function stake(uint256 _amount) external nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        STEELOFacet steeloFacet = STEELOFacet(ds.contractAddress);
        require(_amount > 0, "Amount must be greater than 0");
        stakes[msg.sender] += _amount;
        isStakeholder[msg.sender] = true;
        steeloFacet.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        STEELOFacet steeloFacet = STEELOFacet(ds.contractAddress);
        require(_amount > 0, "Amount must be greater than 0");
        require(stakes[msg.sender] >= _amount, "Not enough stake");
        stakes[msg.sender] -= _amount;
        if (stakes[msg.sender] == 0) {
            isStakeholder[msg.sender] = false;
        }
        steeloFacet.safeTransfer(msg.sender, _amount);
        emit Unstaked(msg.sender, _amount);
    }

    // Placeholder for actual reward calculation logic
    function calculateReward(address stakeholder) internal view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 totalStaked = getTotalStaked(); // This would sum all staked amounts
        uint256 stakeholderAmount = stakes[stakeholder];
        StakeDuration = ds.stakeDuration[stakeholder]; // Assuming stake duration is tracked

        // Assuming a total reward pool available for distribution
        uint256 totalRewardPool = ds.totalRewardPool; // This should be managed and updated separately

        if(totalStaked == 0) return 0; // Prevent division by zero

        // Calculate the proportion of the total staked amount that the stakeholder owns
        uint256 stakeholderShare = (stakeholderAmount * totalRewardPool) / totalStaked;

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
    
    function distributeRewards() external nonReentrant onlyOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        STEELOFacet steeloFacet = STEELOFacet(ds.contractAddress);
        uint256 totalStaked = getTotalStaked();
        require(totalStaked > 0, "No stakes to distribute rewards to");

        uint256 totalRewardPool = totalRewardPool; // Ensure this value is managed and funded
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
    function getTotalStaked() internal view returns (uint256 totalStaked) {
        address[] memory stakeholders = stakeholders; // Assume this is a dynamic array tracking all stakeholders
        for (uint i = 0; i < stakeholders.length; i++) {
            totalStaked += stakes[stakeholders[i]];
        }
        return totalStaked;
    }

    // Use the automatically generated getter function
    bool isStakeholder = contractInstance.isStakeholder(_user);

    function stakeAmount(address _user) external view returns (uint256) {
        return stakes[_user];
    }
}