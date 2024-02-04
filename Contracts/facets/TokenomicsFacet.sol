// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/LibDiamond.sol";

contract TokenomicsFacet is ERC20, Ownable {
    // Constants
    address public owner;
    uint256 public constant TGE_AMOUNT = 25_000_000 * 1e18 /* Assuming 25 million tokens for TGE */;
    uint256 public steezTransactionCount = 0; // Tracking $Steez transactions, to be updated by an oracle or another mechanism
    uint256 public steezTransitionCount = 1e9; // 1 billion transactions to transition to deflationary
    uint256 public steeloCurrentPrice; // Updated by oracle
    address public treasury; // initialised in the constructer
    uint256 public totalMinted; uint256 public totalBurned;
    uint256 public lastMintEvent; uint256 public lastBurnUpdate;
    uint256 public constant pMin = 0.5 ether; // Placeholder value for Pmin
    uint256 public constant pMax = 5 ether; // Placeholder value for Pmax
    uint256 public rho = 1 ether; // Base rate of token generation
    uint256 public alpha = 10; // Fine-tuning factor for supply cap above Pmax
    uint256 public beta = 10; // Fine-tuning factor for supply cap below Pmin
    uint256 public constant BURN_THRESHOLD = 1e9; // 1 billion $Steez transactions threshold
    bool public isDeflationary = false;

    // Events
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event SupplyCapUpdated(uint256 newCap);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDistributed(address indexed user, uint256 amount);

    // Constructor sets up initial state including the TGE
    constructor(address _treasury) ERC20("Steelo", "STEELO") {
        require(_treasury != address(0), "Treasury cannot be the zero address");
        treasury = _treasury;
        _mint(treasury, TGE_AMOUNT);
        lastMintEvent = block.timestamp;
        emit TokensMinted(treasury, TGE_AMOUNT);
    }

    // Function to mint tokens dynamically based on $Steez transactions and current price
    function mintDynamic(uint256 _steezTransactions, uint256 _currentPrice) external onlyOwner {
        uint256 mintAmount = calculatemintAmount(_steezTransactions, _currentPrice); // Calculate the token generation rate
        _mint(treasury, mintAmount);

        // Calculate distribution amounts
        uint256 communityAmount = (mintAmount * 35) / 100; // 35% for Community: circulating supply purchased or airdropped (reward/incentive)
        uint256 foundersAmount = (mintAmount * 20) / 100; // 20% for Founders: with a gradual release over 4 years, including a 1-year cliff
        uint256 treasuryAmount = (mintAmount * 15) / 100; // 15% for Treasury: governance and incentive supply, rewarded 35% of $Steelo mints
        uint256 liquidityProvidersAmount = (mintAmount * 10) / 100; // 10% for Liquidity Providers: rewarded for SIP participations and 55% of $Steelo mints
        uint256 earlyInvestorsAdvisorsAmount = (mintAmount * 10) / 100; // 10% for Early Investors & Advisors: released over 2 years with a 6-month cliff
        uint256 ecosystemProvidersAmount = (mintAmount * 5) / 100; // 5% for Ecosystem Providers: milestone-based distribution, gifted 10% of $Steelo mints
        uint256 exchangeTradersAmount = (mintAmount * 5) / 100; // 5% for Exchange Traders: continuously based on market activities
        
        // Transfer tokens from treasury to each category
        _transfer(treasuryAddress, treasuryAmount);
        _transfer(treasury, communityAddress, communityAmount);
        _transfer(treasury, foundersAddress, foundersAmount);
        _transfer(treasury, liquidityProvidersAddress, liquidityProvidersAmount);
        _transfer(treasury, earlyInvestorsAdvisorsAddress, earlyInvestorsAdvisorsAmount);
        _transfer(treasury, ecosystemProvidersAddress, ecosystemProvidersAmount);
        _transfer(treasury, exchangeTradersAddress, exchangeTradersAmount);

        emit TokensMinted(treasury, mintAmount);
    }

    // Function to update the transaction count and possibly trigger burning
    function updateTransactionCount(uint256 mintAmount) external onlyOwner {
        steezTransactionCount += mintAmount;
        if (!isDeflationary && steezTransactionCount >= steezTransitionCount) {
        isDeflationary = true;
        }
        if (steezTransactionCount >= BURN_THRESHOLD) {
            burnTokens();
        }
    }

    // Function to calculate the token generation rate (mintAmount)
    function calculatemintAmount(uint256 _steezTransactions, uint256 _currentPrice) public view returns (uint256) {
        uint256 f;
        if (_currentPrice >= pMax) {
            f = 1 ether + ((_currentPrice - pMax) * alpha / 100);
        } else if (_currentPrice <= pMin) {
            f = 1 ether - ((pMin - _currentPrice) * beta / 100);
        } else {
            f = 1 ether; // Adjust by ±1% if needed based on specific conditions
        }
        uint256 mintAmount = rho * steezTransactionVolume * f / 1 ether / 1 ether; // Adjusting for ether decimal places
        return mintAmount;
    }

    // Override the _transfer function to mint tokens automatically
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        super._transfer(sender, recipient, amount);

        // Mint tokens based on the phase
        if (isDeflationary) {
            uint256 mintAmount = calculatemintAmount(); // Calculate the amount to mint
            mintDeflationary(mintAmount);
        } else {
            uint256 mintAmount = calculatemintAmount(); // Calculate the amount to mint
            mintInflationary(owner, mintAmount); // Mint to the owner during inflationary phase
        }
    }

    // Function to mint tokens during the inflationary period
    function mintInflationary(address to, uint256 amount) private {
        require(!isDeflationary, "Cannot mint tokens during deflationary period");

        _mint(to, mintAmount);
        totalMinted += mintAmount;
        lastMintEvent = block.timestamp;

        emit TokensMinted(to, mintAmount);
    }

    // Handles transition from inflationary to deflationary phase
    function transitionToDeflationary() external onlyOwner {
        require(msg.sender == owner, "Only the owner can initiate the transition");
        require(!isDeflationary, "Already in deflationary phase");
        require(steezTransactionCount >= steezTransitCount, "Not enough transactions to transition");

        isDeflationary = true;
    }

    // Burn tokens to implement deflationary mechanism
    function burnTokens() private {
        uint256 treasuryBalance = _balanceOf(address(this)); // Get the balance of $Steelo tokens in the contract
        uint256 burnAmount = (treasuryBalance * FEE_RATE / 1000) * burnRate / 100; // Calculate the amount to burn

        require(treasuryBalance >= burnAmount, "Not enough tokens to burn");
        require(burnAmount > 0, "Burn amount must be greater than 0");
        
        _burn(burnAmount);
        totalBurned += burnAmount;
        lastBurnUpdate = block.timestamp;

        emit TokensBurned(burnAmount);
    }

    // Function to adjust the burn rate, can be called through governance decisions (SIPs)
    function adjustBurnRate(uint256 _newRate) external onlyOwner {
        require(_newRate > 0, "Burn rate must be greater than 0");
        require(_newRate <= burnRate * 110 / 100 && _newRate >= burnRate * 90 / 100, "New rate must be within 10% of the current rate");

        burnRate = _newRate;
        emit BurnRateUpdated(_newRate);
    }

    // Function to adjust the mint rate, can be called through governance decisions (SIPs)
    function adjustMintRate(uint256 _newRate) external onlyOwner {
        require(_newRate > 0, "Mint rate must be greater than 0");
        require(_newRate <= mintRate * 110 / 100 && _newRate >= mintRate * 90 / 100, "New rate must be within 10% of the current rate");

        mintRate = _newRate;
        emit MintRateUpdated(_newRate);
    }

    // Override the _transfer function to mint tokens automatically
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        super._transfer(sender, recipient, amount);

        // Only mint tokens if the system is in the deflationary phase
        if (isDeflationary) {
            uint256 _steezTransactions = getSteezTransactions(); // Replace with your logic to get _steezTransactions
            uint256 _currentPrice = getCurrentPrice(); // Replace with your logic to get _currentPrice
            
            uint256 mintAmount = calculatemintAmount(_steezTransactions, _currentPrice); // Calculate the amount to mint
            mintDeflationary(mintAmount);
        }
    }

    // Function to mint tokens during the deflationary period
    function mintDeflationary(uint256 mintAmount) private {
        require(isDeflationary, "Cannot mint tokens during inflationary period");

        steelo.mint(treasury, mintAmount);
        totalMinter += mintAmount;
        lastMintEvent = block.timestamp;

        emit TokensMinted(treasury, mintAmount);
    }

    // Function to get the owner's address
    function getOwner() public view returns (address) {
        return owner();
    }

    // Function to transfer tokens from one user to another
    function tokenTransfer(address recipient, uint256 amount) external {
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(amount <= balanceOf(msg.sender), "Not enough tokens");

        _transfer(msg.sender, recipient, amount);
    }

    // Example function to update transaction volume and current price
    function updateParameters(uint256 _steezTransactionCount, uint256 _currentPrice) external {
        steezTransactionCount = _steezTransactionCount;
        SteelocurrentPrice = _currentPrice;
    }
}