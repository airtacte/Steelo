// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./libraries/LibDiamond.sol";

contract STEELOFacet is 
    ERC20, 
    OwnableUpgradable, 
    PausableUpgradable, 
    ReentrancyGuard, 
    ChainlinkClient, 
    ISteeloFacet {

    using LibDiamond for LibDiamond.DiamondStorage;

    // Events
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(uint256 amount);
    event MintRateUpdated(uint256 newMintRate);
    event BurnRateUpdated(uint256 newBurnRate);
    event steeloTGEExecuted(uint256 tgeAmount);

    function initialize(
        address _treasury,
        address _oracle,
        string memory _jobId,
        uint256 _fee,
        address _linkToken
    ) public initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        __ERC20_init("Steelo", "STEELO");
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

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
    function steeloTGE(uint256 _steezTransactions, uint256 _currentPrice) external onlyOwner nonReentrant {
        require(!ds.tgeExecuted, "steeloTGE can only be executed once");
        require(_steezTransactions > 0, "_steezTransactions must be greater than 0");
        require(_currentPrice > 0, "_currentPrice must be greater than 0");
        require(totalSupply() == ds.TGE_AMOUNT, "steeloTGE can only be called for the Token Generation Event");
        
        uint256 tgeAmount = calculateMintAmount(_steezTransactions, _currentPrice); // This function may also need adjustment

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

        ds.tgeExecuted = true; // Update the flag in the shared storage
        emit TokensMinted(ds.treasury, tgeAmount);
        emit steeloTGEExecuted(tgeAmount); // Emit an event for the TGE execution
    }

    // Override the _transfer function to mint tokens automatically
    function _transfer(address sender, address recipient, uint256 amount) internal override nonReentrant {
        super._transfer(sender, recipient, amount);
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // Only mint tokens if the system is in the deflationary phase
        if (ds.isDeflationary) {
            uint256 burnAmount = calculateBurnAmount(amount); // Calculate the amount to burn
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

    // Unified minting function
    function steeloMint(uint256 _steezTransactions, uint256 _currentPrice) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(totalSupply() > ds.TGE_AMOUNT, "steeloMint can only be called after the TGE");
        require(_steezTransactions > 0, "_steezTransactions must be greater than 0");
        require(_currentPrice > 0, "_currentPrice must be greater than 0");
        
        uint256 mintAmount = calculateMintAmount(_steezTransactions, _currentPrice);
        distributeMintedTokens(mintAmount); 
    }

    // Calculates the amount to mint based on transaction count and current price
    function calculateMintAmount(uint256 _steezTransactions, uint256 _currentPrice) public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 adjustmentFactor = 1 ether;
        if (_currentPrice >= ds.pMax) {
            adjustmentFactor += (_currentPrice - ds.pMax) * ds.alpha / 100;
        } else if (_currentPrice <= ds.pMin) {
            adjustmentFactor -= (ds.pMin - _currentPrice) * ds.beta / 100;
        } else {
            adjustmentFactor += adjustmentFactor / 100; // 1% adjustment when Pcurrent is within Pmin and Pmax
        }
        uint256 mintAmount = ds.rho * _steezTransactions * adjustmentFactor / 1 ether / 1 ether;
        return mintAmount;
    }

    // Calculate the Supply Cap to use in the minting function
    function calculateSupplyCap(uint256 _currentPrice) public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 currentSupply = totalSupply();
        uint256 supplyCap;
        if (_currentPrice < ds.pMin) {
            supplyCap = currentSupply - ds.delta * (ds.pMin - _currentPrice) * currentSupply / 1 ether;
        } else {
            supplyCap = currentSupply; // maintain the current supply cap if Pcurrent is within or above the target range
        }
        return supplyCap;
    }

    // Function to calculate the amount to burn based on the burn rate
    function calculateBurnAmount(uint256 amount) private view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return amount * ds.burnRate / 10000; // Using ds.burnRate
    }
    
    // Function to adjust the mint rate, can be called through governance decisions (SIPs)
    function adjustMintRate(uint256 _newMintRate) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_newMintRate > 0, "Mint rate must be greater than 0");
        require(_newMintRate <= ds.mintRate * 110 / 100 && _newMintRate >= ds.mintRate * 90 / 100, "New rate must be within 10% of the current rate"); // To amend

        ds.mintRate = _newMintRate;
        emit MintRateUpdated(_newMintRate);
    }

    // Function to adjust the burn rate, can be called through governance decisions (SIPs)
    function adjustBurnRate(uint256 _newBurnRate) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_newBurnRate > 0, "Burn rate must be greater than 0");
        require(_newBurnRate <= ds.burnRate * 110 / 100 && _newBurnRate >= ds.burnRate * 90 / 100, "New rate must be within 10% of the current rate"); // To amend

        ds.burnRate = _newBurnRate;
        emit BurnRateUpdated(_newBurnRate);
    }
    
    // Burn tokens to implement deflationary mechanism
    function burnTokens() private {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 treasuryBalance = balanceOf(address(this)); // Assuming _balanceOf was a typo, use balanceOf
        uint256 burnAmount = (SteeloCurrentPrice * ds.FEE_RATE / 1000) * ds.burnRate / 100;

        require(treasuryBalance >= burnAmount, "Not enough tokens to burn");
        require(burnAmount > 0, "Burn amount must be greater than 0");
        
        _burn(address(this), burnAmount); // Assuming _burn requires an address argument
        ds.totalBurned += burnAmount;
        ds.lastBurnUpdate = block.timestamp;

        emit TokensBurned(burnAmount);
    }

    // Function to get the owner's address
    function getOwner() public view returns (address) {
        return owner();
    }

    // Function to update the transaction count and possibly trigger burning
    function updateSteezTransactionCount(uint256 mintAmount) external onlyOwner nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.steezTransactionCount += mintAmount;
        if (!ds.isDeflationary && ds.steezTransactionCount > 0) {
            ds.isDeflationary = true;
        }
        if (ds.steezTransactionCount >= ds.BURN_THRESHOLD) {
            burnTokens();
        }
    }

    // Example function to update transaction volume and current price
    function updateParameters(uint256 _steezTransactionCount, uint256 _currentPrice) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.steezTransactionCount = _steezTransactionCount;
        ds.steeloCurrentPrice = _currentPrice;
    }

    // Function to make a GET request to the Chainlink oracle
    function requestVolumeData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000, address(this), this.fulfill.selector);
        req.add("get", "https://us-central1-steelo-47.cloudfunctions.net/functionName");
        req.add("path", "volume"); // Specify the JSON path that leads to the data of interest
        return sendChainlinkRequestTo(ds.oracle, request, ds.fee);
    }

    // Function to receive the response from the Chainlink oracle
    function fulfill(bytes32 _requestId, uint256 _steezTransactionCount) public recordChainlinkFulfillment(_requestId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.steezTransactionCount = _steezTransactionCount;
        checkForMintOrBurn(); // Ensure this function also accesses shared state via ds
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