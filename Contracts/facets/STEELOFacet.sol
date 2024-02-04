// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./libraries/LibDiamond.sol";

contract STEELOFacet is ERC20, Ownable, ChainLinkClient {

    // Chainlink parameters
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public volume;

    // Constants
    int256 public steezTransactionCount = -1e90; // Tracking against tokenomic transition, Updated by oracle
    uint256 public constant TGE_AMOUNT = 25_000_000 * 1e18 /* Assuming 25 million tokens for TGE */;
    uint256 public steeloCurrentPrice; // Updated by oracle
    uint256 public totalMinted; 
    uint256 public totalBurned;
    uint256 public lastMintEvent; 
    uint256 public lastBurnUpdate;
    uint256 public TGE   uint256 public rewardDynamic;
    uint256 public burnRate;
    uint256 public mintRate;
    uint256 public constant pMin = 0.5 ether; // Placeholder value for Pmin
    uint256 public constant pMax = 5 ether; // Placeholder value for Pmax
    uint256 public rho = 1 ether; // Base rate of token generation
    uint256 public alpha = 10; // Fine-tuning factor for supply cap above Pmax
    uint256 public beta = 10; // Fine-tuning factor for supply cap below Pmin
    uint256 public constant BURN_THRESHOLD = 1e9; // 1 billion $Steez transactions threshold
    uint256 public FEE_RATE = 25; // 2.5% fee rate to Steelo inc.
    address public treasury; // initialised in the constructer
    address public liquidityProviders = 0x22a909748884b504bb3BDC94FAE155aaa917416D;
    address public ecosystemProviders = 0x5dBfD5E645FF0714dc71c3cbcADAAdf163d5971D;
    address public steeloAddresss = 0x45F9B54cB97970c0E798dB0FDF2b8076Cdf57d25;
    address public foundersAddress = 0x0620F316431EE739a1c1EeD54980aF5EAF5B8E49;
    address public earlyInvestorsAddress = 0x6Eaa165659fbd96C10DBad3C3A89396225aEEde8;
    address public communityAddress = 0xB6912a7F733287BE95Aca28E1C563FA3Ed0BeFde;
    bool public isDeflationary = false;

    // Events
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event SupplyCapUpdated(uint256 newCap);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDistributed(address indexed user, uint256 amount);

    // Constructor sets up initial state including the TGE
    constructor(address _treasury, address _oracle, string memory _jobId, uint256 _fee, address _link) ERC20("Steelo", "STEELO") {
        setPublicChainlinkToken();
        require(_treasury != address(0), "Treasury cannot be the zero address");
        treasury = _treasury;
        _mint(treasury, TGE_AMOUNT);
        emit TokensMinted(treasury, TGE_AMOUNT);
        if (_link == address(0)) {
            // If the _link address is not provided, use the default LINK token address
            setPublicChainlinkToken();
        } else {
            // If the _link address is provided, set it as the LINK token address
            setChainlinkToken(_link);
        }
        lastMintEvent = block.timestamp;
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee;
    }

    // Function to mint tokens dynamically based on $Steez transactions and current price
    function TGEDynamic(uint256 _steezTransactions, uint256 _currentPrice) external onlyOwner {
        require(_steezTransactions > 0, "_steezTransactions must be greater than 0");
        require(_currentPrice > 0, "_currentPrice must be greater than 0");
        require(totalSupply() == TGE_AMOUNT, "TGE only be called for the Token Generation Event ");
        uint256 mintAmount = calculateMintAmount(_steezTransactions, _currentPrice); // Calculate the token generation rate

        // Calculate distribution amounts 
        uint256 communityAmount = (mintAmount * 35) / 100; // 35% for Community: airdrops, bounties, and ambassadorships
        uint256 foundersAmount = (mintAmount * 20) / 100; // 20% for Founders: released over 4 years with a 1-year cliff
        uint256 earlyInvestorsAmount = (mintAmount * 10) / 100; // 10% for Early Investors: released over 2 years with a 6-month cliff

        // Mint tokens to treasury        
        _mint(treasury, mintAmount);

        // Transfer tokens from treasury to each category
        // NEED TO CREATE ESCROW+SMART WALLET GENERATION & ASSIGNMENT FUNCTION TO ENSURE FUNDS CAN BE ALLOCATED POST-MINT
        _transfer(treasury, communityAddress, communityAmount);
        _transfer(treasury, foundersAddress, foundersAmount);
        _transfer(treasury, earlyInvestorsAddress, earlyInvestorsAmount);

        emit TokensMinted(treasury, mintAmount);
    }

    function rewardDynamic(uint256 _steezTransactions, uint256 _currentPrice) external onlyOwner {
        require(totalSupply() > TGE_AMOUNT, "rewardDynamic can only be called after the TGE");
        uint256 rewardAmount = calculateRewardAmount(_steezTransactions, _currentPrice); // Calculate the reward amount

        // Calculate distribution amounts 
        uint256 treasuryAmount = (rewardAmount * 35) / 100; // 35% for Treasury: governance, airdrop and incentive supply
        uint256 liquidityProvidersAmount = (rewardAmount * 55) / 100; // 55% of $Steelo mints
        uint256 ecosystemProvidersAmount = (rewardAmount * 10) / 100; // payed through 10% of $Steelo mints
       
        _mint(treasury, rewardAmount);

        // Transfer tokens from treasury to each category
        // NEED TO CREATE "SMART WALLET" GENERATION & ASSIGNMENT FUNCTION TO ENSURE FUNDS CAN BE ALLOCATED POST-MINT
        _transfer(treasury, treasury, treasuryAmount);
        _transfer(treasury, liquidityProviders, liquidityProvidersAmount);
        _transfer(treasury, ecosystemProviders, ecosystemProvidersAmount);

        emit TokensMinted(treasury, rewardAmount);
    }

    // Function to update the transaction count and possibly trigger burning
    function updateTransactionCount(uint256 mintAmount) external onlyOwner {
        steezTransactionCount += mintAmount;
        if (!isDeflationary && steezTransactionCount >= 0) {
        isDeflationary = true;
        }
        if (steezTransactionCount >= BURN_THRESHOLD) {
            burnTokens();
        }
    }

    // Function to calculate the token generation rate (mintAmount)
    function calculateMintAmount(uint256 _steezTransactions, uint256 _currentPrice) public view returns (uint256) {
        uint256 f;
        if (_currentPrice >= pMax) {
            f = 1 ether + ((_currentPrice - pMax) * alpha / 100);
        } else if (_currentPrice <= pMin) {
            f = 1 ether - ((pMin - _currentPrice) * beta / 100);
        } else {
            f = 1 ether; // Adjust by ±1% if needed based on specific conditions
        }
        uint256 mintAmount = rho * steezTransactionCount * f / 1 ether / 1 ether; // Adjusting for ether decimal places
        return mintAmount;
    }

    // Override the _transfer function to mint tokens automatically
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        super._transfer(sender, recipient, amount);

        // Mint tokens based on the phase
        if (isDeflationary) {
            uint256 mintAmount = calculateMintAmount(); // Calculate the amount to mint
            mintDeflationary(mintAmount);
        } else {
            uint256 mintAmount = calculateMintAmount(); // Calculate the amount to mint
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

        // Increment steezTransactionCount by the number of $Steez transactions
        steezTransactionCount += getSteezTransactionCount();

        // Check if steezTransactionCount is >= 0
        if (steezTransactionCount >= 0) {
            isDeflationary = true;
        }
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
            uint256 _steezTransactionCount = getSteezTransactionCount(); // Replace with your logic to get _steezTransactions
            uint256 _steeloCurrentPrice = getSteeloCurrentPrice(); // Replace with your logic to get _currentPrice
            
            uint256 mintAmount = calculateMintAmount(_steezTransactions, _currentPrice); // Calculate the amount to mint
            mintDeflationary(mintAmount);
        }
    }

    // Function to mint tokens during the deflationary period
    function mintDeflationary(uint256 mintAmount) private {
        require(isDeflationary, "Cannot mint tokens during inflationary period");

        _mint(treasury, mintAmount);
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

        uint256 feeAmount = (amount * FEE_RATE) / 10000; // Calculate the fee amount (2.5% of the transfer amount)
        uint256 transferAmount = amount - feeAmount; // Calculate the transfer amount after deducting the fee

        _transfer(msg.sender, recipient, transferAmount); // Transfer the tokens to the recipient
        _transfer(msg.sender, steeloAddress, feeAmount); // Transfer the fee to the steeloAddress
    }

    // Example function to update transaction volume and current price
    function updateParameters(uint256 _steezTransactionCount, uint256 _currentPrice) external {
        steezTransactionCount = _steezTransactionCount;
        SteelocurrentPrice = _currentPrice;
    }

    // Function to make a GET request to the Chainlink oracle
    function requestVolumeData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000, address(this), this.fulfill.selector);
        req.add("get", "https://us-central1-steelo-47.cloudfunctions.net/functionName");
        req.add("path", "volume");
        return sendChainlinkRequestTo(0xb83E47C2bC239B3bf370bc41e1459A34b41238D0, request, fee);
    }

    // Function to receive the response from the Chainlink oracle
    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
        volume = _volume;
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