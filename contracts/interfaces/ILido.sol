// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ILido {
    /**
     * @notice Stakes ETH and mints stETH tokens.
     * @param _amount Amount of ETH to stake.
     * @return Amount of stETH minted.
     */
    function submit(address _referral) external payable returns (uint256);

    /**
     * @notice Returns the current amount of stETH for 1 ETH, including fees.
     * @return Current stETH exchange rate.
     */
    function getStETHByETH(uint256 _ethAmount) external view returns (uint256);

    /**
     * @notice Returns the total amount of staked ETH managed by the protocol.
     * @return Total staked ETH.
     */
    function getTotalPooledEther() external view returns (uint256);
}