// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

interface ISteeloFacet {
    /**
     * @notice Mints Steelo tokens to an address.
     * @param _to Address to mint tokens to.
     * @param _amount Amount of tokens to mint.
     */
    function mint(address _to, uint256 _amount) external;

    /**
     * @notice Burns Steelo tokens from an address.
     * @param _from Address to burn tokens from.
     * @param _amount Amount of tokens to burn.
     */
    function burn(address _from, uint256 _amount) external;

    // Initializes the contract with essential parameters.
    function initialize(address _treasury, string memory _jobId, uint256 _fee, address _linkToken) external;

    // Executes the Token Generation Event (TGE) based on specific criteria.
    function steeloTGE(uint256 _steezTransactions, uint256 _currentPrice) external;

    // Mints Steelo tokens dynamically based on transaction volume and current market conditions.
    function steeloMint(uint256 _steezTransactions, uint256 _currentPrice) external;

    // Adjusts the minting rate for Steelo tokens.
    function adjustMintRate(uint256 _newMintRate) external;

    // Adjusts the burning rate for Steelo tokens.
    function adjustBurnRate(uint256 _newBurnRate) external;

    // Burns Steelo tokens to implement a deflationary mechanism.
    function burnTokens() external;

    // Updates the transaction count, possibly triggering a deflationary action.
    function updateSteezTransactionCount(uint256 mintAmount) external;

    // Transfers Steelo tokens from one account to another.
    function tokenTransfer(address recipient, uint256 amount) external;
}

interface ISteeloStakingFacet {
}