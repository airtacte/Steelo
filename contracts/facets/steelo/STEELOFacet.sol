// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { STEEZFacet } from "../steez/STEEZFacet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract STEELOFacet is ERC20, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuard, ChainlinkClient {
    STEEZFacet.Steez public steez;
    STEEZFacet.Investor public investor;
    using LibDiamond for LibDiamond.DiamondStorage;

    // Events
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(uint256 amount);
    event MintRateUpdated(uint256 newMintRate);
    event BurnRateUpdated(uint256 newBurnRate);
    event steeloTGEExecuted(uint256 tgeAmount);

    int256 public steezTransactionCount = -1e9; 
    uint256 public steeloCurrentPrice;
    uint256 public totalMinted; 
    uint256 public totalBurned;
    uint256 public lastMintEvent; 
    uint256 public lastBurnEvent;
    uint256 public mintAmount;
    uint256 public burnAmount;
    uint256 private burnRate;
    uint256 private mintRate;
    bool public isDeflationary;
    bool public tgeExecuted;

    function initialize(address _treasury, address _oracle, string memory _jobId, uint256 _fee, address _linkToken) public initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ERC20("Steelo", "STEELO");

        require(_treasury != address(0), "Treasury cannot be the zero address");

        // Setting up Chainlink
        setChainlinkToken(_linkToken);
        ds.oracle = _oracle;
        ds.jobId = LibDiamond.stringToBytes32(_jobId);
        ds.fee = _fee;
        ds.treasury = _treasury;
        _mint(_treasury, ds.TGE_AMOUNT);
        emit TokensMinted(_treasury, ds.TGE_AMOUNT);
        ds.lastMintEvent = block.timestamp;
    }

    // Function to mint tokens dynamically based on $Steez transactions and current price
    function steeloTGE(uint256 _steeloCurrentPrice) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        STEEZFacet.Steez memory localSteez = STEEZFacet(ds.steezFacetAddress).steez(creatorIdId);
        require(!ds.tgeExecuted, "steeloTGE can only be executed once");
        require(localSteez.transactionCount == 0, "steezTransactionCount must be equal to 0");
        require(steeloCurrentPrice > 0, "steeloCurrentPrice must be greater than 0");
        require(totalSupply() == ds.TGE_AMOUNT, "steeloTGE can only be called for the Token Generation Event");
        
        uint256 tgeAmount = calculateMintAmount(localSteez.steezTransactionCount, steeloCurrentPrice); // This function may also need adjustment

        // Calculate distribution amounts using ds references for percentages
        uint256 communityAmount = (tgeAmount * ds.communityTGE) / 100;
        uint256 foundersAmount = (tgeAmount * ds.foundersTGE) / 100; // Assume these are now in ds
        uint256 earlyInvestorsAmount = (tgeAmount * ds.earlyInvestorsTGE) / 100;
        uint256 treasuryAmount = (tgeAmount * ds.trasuryTGE) / 100;

        // Mint tokens directly to addresses
        _mint(ds.communityAddress, communityAmount);
        _mint(ds.foundersAddress, foundersAmount);
        _mint(ds.earlyInvestorsAddress, earlyInvestorsAmount);
        _mint(ds.treasury, treasuryAmount);

        tgeExecuted = true; // Update the flag in the shared storage
        emit TokensMinted(ds.treasury, tgeAmount);
        emit steeloTGEExecuted(tgeAmount); // Emit an event for the TGE execution
    }

    function calculateTotalTransactions() public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        STEEZFacet.Steez memory localSteez = STEEZFacet(ds.steezFacetAddress).steez(creatorId);
        uint256 totalTransactions = 0;
        for (uint256 i = 0; i < localSteez.steezIds.length; i++) {
            totalTransactions += STEEZFacet(address(this)).steez(localSteez.steezIds[i]).transactionCount;
        }
        steezTransactionCount += int256(totalTransactions); // Make sure to cast totalTransactions to int256

        // Check if steezTransactionCount has reached 0 and transition to deflationary system
        if (steezTransactionCount >= 0) {
            // Transition to deflationary system
        }
    }

    // Override the _transfer function to mint tokens automatically
    function _transfer(address sender, address recipient, uint256 amount) internal override nonReentrant {
        super._transfer(sender, recipient, amount);
        if (isDeflationary) {
            burnAmount = calculateBurnAmount(amount); // Calculate the amount to burn
            _burn(sender, burnAmount);
        }
    }

    // Function to transfer tokens from one user to another
    function tokenTransfer(address recipient, uint256 amount) external nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(amount <= balanceOf(msg.sender), "Not enough tokens");

        uint256 feeAmount = (amount * ds.FEE_RATE) / 10000;
        uint256 transferAmount = amount - feeAmount;

        _transfer(msg.sender, recipient, transferAmount);
        _transfer(msg.sender, ds.steeloAddress, feeAmount);
    }

    function steeloMint() external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(totalSupply() > ds.TGE_AMOUNT, "steeloMint can only be called after the TGE");
        require(steezTransactionCount > 0, "steezTransactionCount must be greater than 0");
        require(steeloCurrentPrice > 0, "steeloCurrentPrice must be greater than 0");
        
        uint256 steeloMintAmount = calculateMintAmount(steezTransactionCount, steeloCurrentPrice);

        // Calculate distribution amounts using ds references for percentages
        uint256 treasuryAmount = (steeloMintAmount * ds.treasuryMint) / 100;
        uint256 liquidityProvidersAmount = (steeloMintAmount * ds.liquidityProvidersMint) / 100;
        uint256 ecosystemProvidersAmount = (steeloMintAmount * ds.ecosystemProvidersMint) / 100;

        // Mint tokens directly to addresses
        _mint(ds.treasury, treasuryAmount);
        _mint(ds.liquidityProviders, liquidityProvidersAmount);
        _mint(ds.ecosystemProviders, ecosystemProvidersAmount);
    }

    // Calculates the amount to mint based on transaction count and current price
    function calculateMintAmount() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 adjustmentFactor = 1 ether;
        if (steeloCurrentPrice >= ds.pMax) {
            adjustmentFactor += (steeloCurrentPrice - ds.pMax) * ds.alpha / 100;
        } else if (steeloCurrentPrice <= ds.pMin) {
            adjustmentFactor -= (ds.pMin - steeloCurrentPrice) * ds.beta / 100;
        } else {
            adjustmentFactor += adjustmentFactor / 100; // 1% adjustment when Pcurrent is within Pmin and Pmax
        }
        mintAmount = ds.rho * steezTransactionCount * adjustmentFactor / 1 ether / 1 ether;
        return mintAmount;
    }

    // Calculate the Supply Cap to use in the minting function
    function calculateSupplyCap() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 currentSupply = totalSupply();
        uint256 supplyCap;
        if (steeloCurrentPrice < ds.pMin) {
            supplyCap = currentSupply - ds.delta * (ds.pMin - steeloCurrentPrice) * currentSupply / 1 ether;
        } else {
            supplyCap = currentSupply; // maintain the current supply cap if Pcurrent is within or above the target range
        }
        return supplyCap;
    }

    // Function to calculate the amount to burn based on the burn rate
    function calculateBurnAmount() private view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return amount * burnRate / 10000; // Using ds.burnRate
    }
    
    // Function to adjust the mint rate, can be called through governance decisions (SIPs)
    function adjustMintRate() external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_newMintRate > 0 && _newMintRate <= ds.mintRateMax, "Invalid mint rate");
        ds.mintRate = _newMintRate;
        emit MintRateUpdated(_newMintRate);
    }

    // Function to adjust the burn rate, can be called through governance decisions (SIPs)
    function adjustBurnRate() external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_newBurnRate > 0 && _newBurnRate <= ds.burnRateMax, "Invalid burn rate");
        ds.burnRate = _newBurnRate;
        emit BurnRateUpdated(_newBurnRate);
    }
    
    // Burn tokens to implement deflationary mechanism
    function burnTokens() private {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 treasuryBalance = balanceOf(address(this)); // Assuming _balanceOf was a typo, use balanceOf
        burnAmount = (SteeloCurrentPrice * ds.FEE_RATE / 1000) * ds.burnRate / 100;

        require(treasuryBalance >= burnAmount, "Not enough tokens to burn");
        require(burnAmount > 0, "Burn amount must be greater than 0");
        
        _burn(address(this), burnAmount); // Assuming _burn requires an address argument
        totalBurned += burnAmount;
        lastBurnEvent = block.timestamp;

        emit TokensBurned(burnAmount);
    }

    // Function to get the owner's address
    function getOwner() public view returns (address) {
        return owner();
    }


    // Example function to update transaction volume and current price
    function updateParameters() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(steeloCurrentPrice >= ds.pMin && steeloCurrentPrice <= ds.pMax, "Price out of allowed range");
        ds.steezTransactionCount = steezTransactionCount;
        ds.steeloCurrentPrice = steeloCurrentPrice;
        // Logic to determine if minting or burning should occur based on updated parameters
    }

    // Function to make a GET request to the Chainlink oracle
    function requestVolumeData() public returns (bytes32 requestId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        Chainlink.Request memory request = buildChainlinkRequest(ds.jobId, address(this), this.fulfill.selector);
        req.add("get", "https://us-central1-steelo.io.cloudfunctions.net/functionName");
        req.add("path", "volume");
        return sendChainlinkRequestTo(ds.oracle, request, ds.fee);
    }

    // Function to receive the response from the Chainlink oracle
    function fulfill(bytes32 _requestId) public recordChainlinkFulfillment(_requestId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(steezTransactionCount > 0, "Invalid transaction count");
        ds.steezTransactionCount = steezTransactionCount;
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