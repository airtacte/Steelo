// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
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

    // Structs
    STEEZFacet.Steez internal steez;
    STEEZFacet.Investor public investor;

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
    bool public tgeExecuted;
    bool public isDeflationary;
    address public creatorId;

    function initialize(address _treasury, address _oracle, string memory _jobId, uint256 _fee, address _linkToken) public initializer {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        steeloFacetAddress = ds.steeloFacetAddress;
        require(_treasury != address(0), "Treasury cannot be the zero address");
        __ERC20_init("Steelo", "STL");

        // Setting up Chainlink
        setChainlinkToken(_linkToken);
        ds.oracle = _oracle;
        ds.jobId = LibDiamond.stringToBytes32(_jobId);
        ds.fee = _fee;
        ds.treasury = _treasury;
        _mint(_treasury, ds.TGE_AMOUNT);
        emit TokensMinted(_treasury, ds.TGE_AMOUNT);
        lastMintEvent = block.timestamp;
    }

    // Function to mint tokens dynamically based on $Steez transactions and current price
    function steeloTGE(uint256 _steeloCurrentPrice) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        STEEZFacet steezFacet = STEEZFacet(ds.steezFacetAddress);
        STEEZFacet.Steez memory localSteez = steezFacet.steez[creatorId];
        require(!tgeExecuted, "steeloTGE can only be executed once");
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
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        STEEZFacet.Steez memory localSteez = STEEZFacet(ds.steezFacetAddress).steez(creatorId);
        uint256 totalTransactions = 0;
        for (uint256 i = 0; i < localSteez.steezIds.length; i++) {
            totalTransactions += STEEZFacet(address(this)).steez(localSteez.steezIds[i]).transactionCount;
        }
        steezTransactionCount += int256(totalTransactions); // Make sure to cast totalTransactions to int256

        // Check if a billion steez transactions have occured to transition to deflationary tokenomics
        if (steezTransactionCount >= 0) {
            isDeflationary = true;
        }
    }

    // Override the _transfer function to integrate burning mechanism
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        // Calculate the burn amount based on the transaction value
        burnAmount = calculateBurnAmount(amount);
        
        // Check if there's a need to burn from the transaction
        if(burnAmount > 0) {
            // Proceed to burn the calculated amount from the Treasury's balance
            // Assume treasuryBalance tracks the Treasury's $Steelo balance
            require(ds.treasuryBalance >= burnAmount, "Insufficient funds in Treasury for burning");
            _burn(ds.treasury, burnAmount);
            emit TokensBurned(burnAmount);
        }
    }

    // Function to transfer tokens from one user to another
    function tokenTransfer(address recipient, uint256 amount) external nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(amount <= balanceOf(msg.sender), "Not enough tokens");

        uint256 feeAmount = (amount * ds.FEE_RATE) / 10000;
        uint256 transferAmount = amount - feeAmount;

        _beforeTokenTransfer(msg.sender, recipient, transferAmount);
        _beforeTokenTransfer(msg.sender, ds.steeloAddress, feeAmount);
    }

    function steeloMint() external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        require(totalSupply() > ds.TGE_AMOUNT, "steeloMint can only be called after the TGE");
        require(steezTransactionCount > 0, "steezTransactionCount must be greater than 0");
        require(steeloCurrentPrice > 0, "steeloCurrentPrice must be greater than 0");
        
        uint256 steeloMintAmount = calculateMintAmount(steezTransactionCount, steeloCurrentPrice);
        // Assume 1,000

        // Calculate distribution amounts using ds references for percentages
        uint256 treasuryAmount = (steeloMintAmount * ds.treasuryMint) / 100;
        uint256 liquidityProvidersAmount = (steeloMintAmount * ds.liquidityProvidersMint) / 100;
        uint256 ecosystemProvidersAmount = (steeloMintAmount * ds.ecosystemProvidersMint) / 100;

        // 20% extra minting for exchanges like Uniswap and Sushiswap

        // Mint tokens directly to addresses
        _mint(ds.treasury, treasuryAmount);
        _mint(ds.liquidityProviders, liquidityProvidersAmount);
        _mint(ds.ecosystemProviders, ecosystemProvidersAmount);
    }

    // Calculates the amount to mint based on transaction count and current price
    function calculateMintAmount() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
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
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
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
    function calculateBurnAmount(uint256 transactionValue) private view returns (uint256) {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        if(steezTransactionCount >= 0) {          
            burnAmount = transactionValue * ds.FEE_RATE * burnRate / 1e4 / 1e4; // in basis of 1/100 of a percent
            return burnAmount;
        } else {return 0;}
    }
    
    // Function to adjust the mint rate, can be called through governance decisions (SIPs)
    function adjustMintRate(uint256 _newMintRate) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        require(_newMintRate >= ds.MIN_MINT_RATE && _newMintRate <= ds.MAX_MINT_RATE, "Invalid mint rate");
        mintRate = _newMintRate;
        emit MintRateUpdated(_newMintRate);
    }

    // Function to adjust the burn rate, can be called through governance decisions (SIPs)
    function adjustBurnRate(uint256 _newBurnRate) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        require(_newBurnRate >= ds.MIN_BURN_RATE && _newBurnRate <= ds.MAX_BURN_RATE, "Invalid burn rate");
        burnRate = _newBurnRate;
        emit BurnRateUpdated(_newBurnRate);
    }
    
    // Burn tokens to implement deflationary mechanism
    function burnTokens() private {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        uint256 treasuryBalance = balanceOf(address(this)); // Assuming _balanceOf was a typo, use balanceOf
        burnAmount = (steeloCurrentPrice * ds.FEE_RATE / 1000) * burnRate / 100;

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
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        require(steeloCurrentPrice >= ds.pMin && steeloCurrentPrice <= ds.pMax, "Price out of allowed range");
        ds.steezTransactionCount = steezTransactionCount;
        ds.steeloCurrentPrice = steeloCurrentPrice;
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