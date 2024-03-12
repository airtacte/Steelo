// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { STEEZFacet } from "../steez/STEEZFacet.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract STEELOFacet is ERC20Upgradeable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuard, ChainlinkClient {
    address steeloFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;
     
    // Events
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(uint256 amount);
    event MintRateUpdated(uint256 newMintRate);
    event BurnRateUpdated(uint256 newBurnRate);
    event steeloTGEExecuted(uint256 tgeAmount);
    event DeflationaryTokenomicsActivated();

    function initialize(address _treasury, address _oracle, string memory _jobId, uint256 _fee, address _linkToken) public initializer {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        steeloFacetAddress = ds.steeloFacetAddress;
        
        require(_treasury != address(0), "Treasury cannot be the zero address");
        __ERC20_init("Steelo", "STLO");

        // Set Chainlink parameters
        setChainlinkOracle(_oracle);
        ds.oracle = _oracle;
        ds.jobId = LibDiamond.stringToBytes32(_jobId);
        ds.fee = _fee;

        // Set the Treasury address and mint the initial supply
        _mint(ds.constants.treasury, ds.constants.TGE_AMOUNT);
        ds.lastMintEvent = block.timestamp;
        
        emit TokensMinted(ds.constants.treasury, ds.constants.TGE_AMOUNT);
    }

    // Function to mint tokens dynamically based on $Steez transactions and current price
    function steeloTGE(uint256 _steeloCurrentPrice) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        require(!ds.tgeExecuted, "steeloTGE can only be executed once");
        require(ds.totalTransactionCount == 0, "TransactionCount must be equal to 0");
        require(ds.steeloCurrentPrice > 0, "steeloCurrentPrice must be greater than 0");
        require(totalSupply() == ds.constants.TGE_AMOUNT, "steeloTGE can only be called for the Token Generation Event");

        // Calculate distribution amounts using ds references for percentages
        uint256 communityAmount = (ds.constants.TGE_AMOUNT * ds.constants.communityTGE) / 100;
        uint256 foundersAmount = (ds.constants.TGE_AMOUNT * ds.constants.foundersTGE) / 100; // Assume these are now in ds
        uint256 earlyInvestorsAmount = (ds.constants.TGE_AMOUNT * ds.constants.earlyInvestorsTGE) / 100;
        uint256 treasuryAmount = (ds.constants.TGE_AMOUNT * ds.constants.trasuryTGE) / 100;

        // Mint tokens directly to addresses
        _mint(ds.constants.communityAddress, communityAmount);
        _mint(ds.constants.foundersAddress, foundersAmount);
        _mint(ds.constants.earlyInvestorsAddress, earlyInvestorsAmount);
        _mint(ds.constants.treasury, treasuryAmount);

        ds.tgeExecuted = true; // Update the flag in the shared storage
        emit TokensMinted(ds.constants.treasury, ds.constants.TGE_AMOUNT);
        emit steeloTGEExecuted(ds.constants.TGE_AMOUNT); // Emit an event for the TGE execution
    }

    function getTotalTransactionCount() public view returns (uint256 totalTransactionCount) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        int256 transactionCount = 0;
        uint256 length = ds.allCreatorIds.length;
        for (uint256 i = 0; i < length; i++) {
            uint256 creatorId = ds.allCreatorIds[i];
            transactionCount += ds.steez[creatorId].transactionCount;
        }

        // Check if a billion steez transactions have occurred to transition to deflationary tokenomics
        if (transactionCount >= 0 && !ds.isDeflationary) {
            ds.isDeflationary = true;
            emit DeflationaryTokenomicsActivated();
        }

        return transactionCount;
    }

    // Override the _transfer function to integrate burning mechanism
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        // Calculate the burn amount based on the transaction value
        ds.burnAmount = calculateBurnAmount(amount);
        
        // Check if there's a need to burn from the transaction
        if(ds.burnAmount > 0) {
            // Proceed to burn the calculated amount from the Treasury's balance
            // Assume treasuryBalance tracks the Treasury's $Steelo balance
            require(ds.treasuryBalance >= ds.burnAmount, "Insufficient funds in Treasury for burning");
            _burn(ds.treasury, ds.burnAmount);
            emit TokensBurned(ds.burnAmount);
        }
    }

    // Function to transfer tokens from one user to another
    function tokenTransfer(address recipient, uint256 amount) external nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        require(recipient != address(0), "Cannot transfer to the zero address");
        require(amount <= balanceOf(msg.sender), "Not enough tokens");

        uint256 feeAmount = (amount * ds.constants.FEE_RATE) / 10000;
        uint256 transferAmount = amount - feeAmount;

        _beforeTokenTransfer(msg.sender, recipient, transferAmount);
        _beforeTokenTransfer(msg.sender, ds.constants.steeloAddress, feeAmount);
    }

    function steeloMint() external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        require(totalSupply() > ds.constants.TGE_AMOUNT, "steeloMint can only be called after the TGE");
        require(ds.totalTransactionCount > 0, "ds.totalTransactionCount must be greater than 0");
        require(ds.steeloCurrentPrice > 0, "steeloCurrentPrice must be greater than 0");
        
        ds.mintAmount = calculateMintAmount(ds.totalTransactionCount, ds.steeloCurrentPrice);
        // Assume 1,000

        // Calculate distribution amounts using ds references for percentages
        uint256 treasuryAmount = (ds.mintAmount * ds.constants.treasuryMint) / 100;
        uint256 liquidityProvidersAmount = (ds.mintAmount * ds.constants.liquidityProvidersMint) / 100;
        uint256 ecosystemProvidersAmount = (ds.mintAmount * ds.constants.ecosystemProvidersMint) / 100;

        // 20% extra minting for exchanges like Uniswap and Sushiswap (TBC)

        ds.totalMinted += ds.mintAmount;
        ds.lastMintEvent = block.timestamp;

        // Mint tokens directly to addresses
        _mint(ds.constants.treasury, treasuryAmount);
        _mint(ds.constants.liquidityProviders, liquidityProvidersAmount);
        _mint(ds.constants.ecosystemProviders, ecosystemProvidersAmount);

        emit TokensMinted(ds.constants.treasury, ds.mintAmount);
    }

    // Calculates the amount to mint based on transaction count and current price
    function calculateMintAmount() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        uint256 adjustmentFactor = 1 ether;
        if (ds.steeloCurrentPrice >= ds.constants.pMax) {
            adjustmentFactor += (ds.steeloCurrentPrice - ds.constants.pMax) * ds.alpha / 100;
        } else if (ds.steeloCurrentPrice <= ds.constants.pMin) {
            adjustmentFactor -= (ds.constants.pMin - ds.steeloCurrentPrice) * ds.constants.beta / 100;
        } else {
            adjustmentFactor += adjustmentFactor / 100; // 1% adjustment when Pcurrent is within Pmin and Pmax
        }
        ds.mintAmount = ds.constants.rho * ds.totalTransactionCount * adjustmentFactor / 1 ether / 1 ether;
        return ds.mintAmount;
    }

    // Calculate the Supply Cap to use in the minting function
    function calculateSupplyCap() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        uint256 currentSupply = totalSupply();
        uint256 supplyCap;
        if (ds.steeloCurrentPrice < ds.constants.pMin) {
            supplyCap = currentSupply - ds.constants.delta * (ds.constants.pMin - ds.steeloCurrentPrice) * currentSupply / 1 ether;
        } else {
            supplyCap = currentSupply; // maintain the current supply cap if Pcurrent is within or above the target range
        }
        return supplyCap;
    }

    // Function to calculate the amount to burn based on the burn rate
    function calculateBurnAmount(uint256 transactionValue) private view returns (uint256) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        if(ds.totalTransactionCount >= 0) {          
            ds.burnAmount = transactionValue * ds.constants.FEE_RATE * ds.burnRate / 1e4 / 1e4; // in basis of 1/100 of a percent
            return ds.burnAmount;
        } else {return 0;}
    }
    
    // Function to adjust the mint rate, can be called through governance decisions (SIPs)
    function adjustMintRate(uint256 _newMintRate) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        require(_newMintRate >= ds.constants.MIN_MINT_RATE && _newMintRate <= ds.constants.MAX_MINT_RATE, "Invalid mint rate");
        ds.mintRate = _newMintRate;

        emit MintRateUpdated(_newMintRate);
    }

    // Function to adjust the burn rate, can be called through governance decisions (SIPs)
    function adjustBurnRate(uint256 _newBurnRate) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        require(_newBurnRate >= ds.constants.MIN_BURN_RATE && _newBurnRate <= ds.constants.MAX_BURN_RATE, "Invalid burn rate");
        ds.burnRate = _newBurnRate;

        emit BurnRateUpdated(_newBurnRate);
    }
    
    // Burn tokens to implement deflationary mechanism
    function burnTokens() private {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        uint256 treasuryBalance = balanceOf(address(this)); // Assuming _balanceOf was a typo, use balanceOf
        ds.burnAmount = (ds.steeloCurrentPrice * ds.constants.FEE_RATE / 1000) * ds.burnRate / 100;

        require(treasuryBalance >= ds.burnAmount, "Not enough tokens to burn");
        require(ds.burnAmount > 0, "Burn amount must be greater than 0");
        
        _burn(address(this), ds.burnAmount); // Assuming _burn requires an address argument
        ds.totalBurned += ds.burnAmount;
        ds.lastBurnEvent = block.timestamp;

        emit TokensBurned(ds.burnAmount);
    }

    // Function to get the owner's address
    function getOwner() public view returns (address) {
        return owner();
    }


    // Example function to update transaction volume and current price
    function updateParameters() external {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        require(ds.steeloCurrentPrice >= ds.constants.pMin && ds.steeloCurrentPrice <= ds.constants.pMax, "Price out of allowed range");
        
        // Logic to determine if minting or burning should occur based on updated parameters
    }

    // Function to make a GET request to the Chainlink oracle
    function requestVolumeData() public returns (bytes32 requestId) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        Chainlink.Request memory request = buildChainlinkRequest(ds.jobId, address(this), this.fulfill.selector);

        request.add("get", "https://us-central1-steelo.io.cloudfunctions.net/functionName");
        request.add("path", "volume");

        return sendChainlinkRequestTo(ds.oracle, request, ds.fee);
    }

    // Function to receive the response from the Chainlink oracle
    function fulfill(bytes32 _requestId) public recordChainlinkFulfillment(_requestId) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        require(ds.totalTransactionCount > 0, "Invalid transaction count");

        // Additional logic for mint or burn based on the new transaction count
    }

    // Helper function to convert a string to a bytes32
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
}