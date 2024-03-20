// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "../app/AccessControlFacet.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract STEELOFacet is ERC20Upgradeable, ChainlinkClient, AccessControlFacet {
    address steeloFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;
     
    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}

    // Chainlink Setup
    address oracleAddress;
    uint256 fee;
    bytes32 key;

    // Events
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(uint256 amount);
    event MintRateUpdated(uint256 newMintRate);
    event BurnRateUpdated(uint256 newBurnRate);
    event steeloTGEExecuted(uint256 tgeAmount);
    event DeflationaryTokenomicsActivated();

    function initialize(
        address _treasury,
        address _oracle,
        string memory _jobId,
        uint256 _fee,
        bytes32 _jobIdKey
    ) public
        onlyRole(accessControl.EXECUTIVE_ROLE()) initializer
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        steeloFacetAddress = ds.steeloFacetAddress;

        require(_treasury != address(0), "Treasury cannot be the zero address");
        __ERC20_init("Steelo", "STLO");

        // Set Chainlink parameters
        setChainlinkOracle(_oracle);
        ds.oracleAddresses[_jobIdKey] = _oracle;
        ds.jobIds[_jobIdKey] = LibDiamond.stringToBytes32(_jobId);
        ds.fees[_jobIdKey] = _fee;

        // Set the Treasury address and mint the initial supply
        _mint(ds.constants.treasury, ds.constants.TGE_AMOUNT);
        ds.lastMintEvent = block.timestamp;
        
        emit TokensMinted(ds.constants.treasury, ds.constants.TGE_AMOUNT);
    }

    // Function to mint tokens dynamically based on $Steez transactions and current price
    function steeloTGE(uint256 _steeloCurrentPrice) external onlyRole(accessControl.EXECUTIVE_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(!ds.tgeExecuted, "STEELOFacet: steeloTGE can only be executed once");
        require(ds.totalTransactionCount == 0, "STEELOFacet: TransactionCount must be equal to 0");
        require(ds.steeloCurrentPrice > 0, "STEELOFacet: steeloCurrentPrice must be greater than 0");
        require(totalSupply() == ds.constants.TGE_AMOUNT, "STEELOFacet: steeloTGE can only be called for the Token Generation Event");

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

    function getTotalTransactionCount() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        int256 transactionCount = -1000000000; // Starting at -1 billion
        uint256 length = ds.allCreatorIds.length;

        for (uint256 i = 0; i < length; i++) {
            uint256 creatorId = ds.allCreatorIds[i];
            transactionCount += int256(ds.steez[creatorId].transactionCount);
        }

        // Ensure transactionCount is non-negative before converting to uint256
        if (transactionCount < 0) {
            // Handle cases where transactionCount is negative.
            // Given your system's requirements, decide how you want to handle this.
            // For instance, you could return 0 or handle it in another specific way.
            return 0;
        } else {
            // Safe to convert to uint256 as transactionCount is non-negative
            return uint256(transactionCount);
        }
    }

    // Override the _beforeTokenTransfer function to integrate custom logic
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // Example: Custom burning logic or other pre-transfer checks/actions
        uint256 burnAmount = calculateBurnAmount(amount);
        if (burnAmount > 0 && from != address(0)) { // Avoid burning on minting
            _burn(from, burnAmount);
            amount -= burnAmount; // Adjust the amount after burning
        }
    }

    // Function to transfer tokens from one user to another
    function tokenTransfer(address recipient, uint256 amount) external onlyRole(accessControl.USER_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(recipient != address(0), "STEELOFacet: Cannot transfer to the zero address");
        require(amount <= balanceOf(msg.sender), "STEELOFacet: Not enough tokens");

        uint256 feeAmount = (amount * ds.constants.FEE_RATE) / 10000;
        uint256 transferAmount = amount - feeAmount;

        _beforeTokenTransfer(msg.sender, recipient, transferAmount);
        _beforeTokenTransfer(msg.sender, ds.constants.steeloAddress, feeAmount);
    }

    // Initiated every 1,000 Steez Transactions (TBBuilt)
    function steeloMint() external onlyRole(accessControl.ADMIN_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(totalSupply() > ds.constants.TGE_AMOUNT, "STEELOFacet: steeloMint can only be called after the TGE");
        require(ds.totalTransactionCount > 0, "STEELOFacet: ds.totalTransactionCount must be greater than 0");
        require(ds.steeloCurrentPrice > 0, "STEELOFacet: steeloCurrentPrice must be greater than 0");
        
        ds.mintAmount = calculateMintAmount(ds.totalTransactionCount, ds.steeloCurrentPrice);

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
    function calculateMintAmount(uint256 totalTransactionCount, uint256 steeloCurrentPrice) public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 adjustmentFactor = 1 ether;
        if (ds.steeloCurrentPrice >= ds.constants.pMax) {
            adjustmentFactor += (ds.steeloCurrentPrice - ds.constants.pMax) * ds.constants.alpha / 100;
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
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

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
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        if(ds.totalTransactionCount >= 0) {          
            ds.burnAmount = transactionValue * ds.constants.FEE_RATE * ds.burnRate / 1e4 / 1e4; // in basis of 1/100 of a percent
            return ds.burnAmount;
        } else {return 0;}
    }
    
    // Function to adjust the mint rate, can be called through governance decisions (SIPs)
    function adjustMintRate(uint256 _newMintRate) external onlyRole(accessControl.ADMIN_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(_newMintRate >= ds.constants.MIN_MINT_RATE && _newMintRate <= ds.constants.MAX_MINT_RATE, "STEELOFacet: Invalid mint rate");
        ds.mintRate = _newMintRate;

        emit MintRateUpdated(_newMintRate);
    }

    // Function to adjust the burn rate, can be called through governance decisions (SIPs)
    function adjustBurnRate(uint256 _newBurnRate) external onlyRole(accessControl.ADMIN_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(_newBurnRate >= ds.constants.MIN_BURN_RATE && _newBurnRate <= ds.constants.MAX_BURN_RATE, "STEELOFacet: Invalid burn rate");
        ds.burnRate = _newBurnRate;

        emit BurnRateUpdated(_newBurnRate);
    }
    
    // Burn tokens to implement deflationary mechanism
    function burnTokens() private {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 treasuryBalance = balanceOf(address(this)); // Assuming _balanceOf was a typo, use balanceOf
        ds.burnAmount = (ds.steeloCurrentPrice * ds.constants.FEE_RATE / 1000) * ds.burnRate / 100;

        require(treasuryBalance >= ds.burnAmount, "STEELOFacet: Not enough tokens to burn");
        require(ds.burnAmount > 0, "STEELOFacet: Burn amount must be greater than 0");
        
        _burn(address(this), ds.burnAmount); // Assuming _burn requires an address argument
        ds.totalBurned += ds.burnAmount;
        ds.lastBurnEvent = block.timestamp;

        emit TokensBurned(ds.burnAmount);
    }

    function verifyTransaction(uint256 _sipId) public view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_sipId < ds.lastSipId, "SIP does not exist");

        // Add your verification logic here
        // For example, check if the SIP has enough votes
        if (ds.sips[_sipId].voteCountForCreator + ds.sips[_sipId].voteCountForCommunity + ds.sips[_sipId].voteCountForSteelo >= 3) {
            return true;
        }

        return false;
    }

    // Example function to update transaction volume and current price
    function updateParameters() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(ds.steeloCurrentPrice >= ds.constants.pMin && ds.steeloCurrentPrice <= ds.constants.pMax, "STEELOFacet: Price out of allowed range");
        
        // Logic to determine if minting or burning should occur based on updated parameters
    }

    // Function to make a GET request to the Chainlink oracle
    function requestVolumeData() public returns (bytes32 requestId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        bytes32 jobId = ds.jobIds[key];
        address oracle = ds.oracleAddresses[key];
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        Chainlink.add(request, "get", "https://us-central1-steelo.io.cloudfunctions.net/functionName");
        Chainlink.add(request, "path", "volume");

        return sendChainlinkRequestTo(oracle, request, ds.fees[key]);
    }

    // Function to receive the response from the Chainlink oracle
    function fulfill(bytes32 _requestId) public recordChainlinkFulfillment(_requestId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(ds.totalTransactionCount > 0, "STEELOFacet: Invalid transaction count");

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