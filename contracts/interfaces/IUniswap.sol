// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity 0.8.20;

interface IUniswap {
}

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

interface IUniswapX {
    // Speculative functionalities considering advanced order book handling and pre-order auctions
    // Function to initiate a pre-order auction
    function initiateAuction(address token, uint256 startPrice, uint256 endPrice, uint256 duration) external;

    // Function for trading in the Launch Trading Pools with logic for handling local stablecoins
    function launchTrade(address tokenSell, address tokenBuy, uint256 amountSell, uint256 amountBuyMin, address to, uint deadline) external returns (uint256 amountBuy);

    // Function to perform exchanges between pools utilizing Uniswap v4's hooks for custom swapping logic
    function poolSwap(address tokenA, address poolA, address tokenB, address poolB, uint256 amountA, uint256 amountAMin, uint256 amountBMin, address to, uint deadline) external returns (uint256 amountB);
}