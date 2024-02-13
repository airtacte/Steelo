// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IUniswapV4 {
    // Function to create a new pool with a specified hook for custom functionality
    function createPool(address tokenA, address tokenB, uint24 fee, address hook) external returns (address pool);

    // Function to add liquidity to a specific pool
    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    // Function to perform a swap from one token to another
    function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin, address to, uint deadline) external returns (uint256 amountOut);

    // Function to remove liquidity from a pool
    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint deadline) external returns (uint256 amountA, uint256 amountB);
}