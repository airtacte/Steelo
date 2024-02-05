// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./libraries/LibDiamond.sol";

contract StakingFacet {

    // Mapping to track staking information for each address
    mapping(address => StakingInfo) public stakers;

    // Events    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);


    // Function to stake SteeloTokens
    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Cannot stake 0");
        StakingInfo storage staking = stakers[msg.sender];
        steeloToken.safeTransferFrom(msg.sender, address(this), _amount);
        staking.amountStaked += _amount;
        staking.timestamp = block.timestamp;
        emit Staked(msg.sender, _amount);
    }

    // Function to unstake SteeloTokens
    function unstake(uint256 _amount) external nonReentrant {
        StakingInfo storage staking = stakers[msg.sender];
        require(_amount > 0 && _amount <= staking.amountStaked, "Invalid unstake amount");
        staking.amountStaked -= _amount;
        steeloToken.safeTransfer(msg.sender, _amount);
        emit Unstaked(msg.sender, _amount);
    }
}