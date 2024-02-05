// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./libraries/LibDiamond.sol";

contract STEELOFacet is ERC20, Ownable, ReentrancyGuard, ChainlinkClient, ISteeloFacet {

    // Chainlink parameters
    address private immutable oracle;
    bytes32 private immutable jobId;
    uint256 private fee;
    uint256 public volume;

    // Constants
    int256 private steezTransactionCount = -1e90; // Tracking against tokenomic transition, Updated by oracle
    uint256 private steeloCurrentPrice; // Updated by oracle
    uint256 public constant TGE_AMOUNT = 25_000_000 * 1e18;
    uint256 public totalMinted; 
    uint256 public totalBurned;
    uint256 public lastMintEvent; 
    uint256 public lastBurnUpdate;
    uint256 public mintAmount;
    uint256 public burnAmount;
    uint256 public burnRate;
    uint256 public mintRate;
    bool public isDeflationary = false;
    bool private tgeExecuted = false;

    // Tokenomic Constants
    uint256 public constant pMin = 0.5 ether;
    uint256 public constant pMax = 5 ether;
    uint256 public rho = 1 ether; // Scaling factor for mint rate
    uint256 public alpha = 10; // Fine-tuning factor for supply cap above Pmax
    uint256 public beta = 10; // Fine-tuning factor for supply cap below Pmin
    uint256 public constant BURN_THRESHOLD = 1e9; // 1 billion $Steez transactions threshold

    // Addresses and distribution rates
    address public treasury; uint256 public trasuryTGE = 35; uint256 public treasuryMint = 35;
    address public liquidityProviders = 0x22a909748884b504bb3BDC94FAE155aaa917416D; uint256 public liquidityProvidersMint = 55;
    address public ecosystemProviders = 0x5dBfD5E645FF0714dc71c3cbcADAAdf163d5971D; uint256 public ecosystemProvidersMint = 10;
    address public foundersAddress = 0x0620F316431EE739a1c1EeD54980aF5EAF5B8E49; uint256 public foundersTGE = 20;
    address public earlyInvestorsAddress = 0x6Eaa165659fbd96C10DBad3C3A89396225aEEde8; uint256 public earlyInvestorsTGE = 10;
    address public communityAddress = 0xB6912a7F733287BE95Aca28E1C563FA3Ed0BeFde; uint256 public communityTGE = 35;
    address public steeloAddresss = 0x45F9B54cB97970c0E798dB0FDF2b8076Cdf57d25;  uint256 public FEE_RATE = 25;

    // Events
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(uint256 amount);
    event MintRateUpdated(uint256 newMintRate);
    event BurnRateUpdated(uint256 newBurnRate);
    event steeloTGEExecuted(uint256 tgeAmount);

    // Constructor sets up initial state including the TGE
    constructor(address _treasury, address _oracle, string memory _jobId, uint256 _fee, address _link) ERC20("Steelo", "STEELO") Ownable() ReentrancyGuard() {
        require(_treasury != address(0), "Treasury cannot be the zero address");

        // Setting up Chainlink
        setChainlinkToken(_linkToken);
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee;
        treasury = _treasury;
        _mint(treasury, TGE_AMOUNT);
        emit TokensMinted(treasury, TGE_AMOUNT);
        lastMintEvent = block.timestamp;
    }

    // Function to mint tokens dynamically based on $Steez transactions and current price
    function steeloTGE(uint256 _steezTransactions, uint256 _currentPrice) external onlyOwner nonReentrant {
        require(!tgeExecuted, "steeloTGE can only be executed once");
        require(_steezTransactions > 0, "_steezTransactions must be greater than 0");
        require(_currentPrice > 0, "_currentPrice must be greater than 0");
        require(totalSupply() == TGE_AMOUNT, "steeloTGE can only be called for the Token Generation Event");
        
        uint256 tgeAmount = calculateMintAmount(_steezTransactions, _currentPrice); // Calculate the token generation rate

        // Calculate distribution amounts 
        uint256 communityAmount = (tgeAmount * communityTGE) / 100;
        uint256 foundersAmount = (tgeAmount * foundersTGE) / 100; // to be released over 4 years with a 1-year cliff
        uint256 earlyInvestorsAmount = (tgeAmount * earlyInvestorsTGE) / 100; // to be released over 2 years with a 6-month cliff
        uint256 treasuryAmount = (tgeAmount * trasuryTGE) / 100;

        // Mint tokens directly to addresses
        // NEED TO CREATE ESCROW+SMART WALLET GENERATION & ASSIGNMENT FUNCTION TO ENSURE FUNDS CAN BE ALLOCATED POST-MINT        
        _mint(communityAddress, communityAmount);
        _mint(foundersAddress, foundersAmount);
        _mint(earlyInvestorsAddress, earlyInvestorsAmount);
        _mint(treasury, treasuryAmount);

        tgeExecuted = true; // Set the TGE executed flag to true
        emit TokensMinted(treasury, tgeAmount);
        emit steeloTGEExecuted(tgeAmount); // Emit an event to indicate that the TGE has been executed
    }

    // Override the _transfer function to mint tokens automatically
    function _transfer(address sender, address recipient, uint256 amount) internal override nonReentrant {
        super._transfer(sender, recipient, amount);

        // Only mint tokens if the system is in the deflationary phase
        if (isDeflationary) {
            uint256 burnAmount = calculateBurnAmount(amount); // Calculate the amount to burn
            _burn(sender, burnAmount);
        }
    }

    // Function to transfer tokens from one user to another
    function tokenTransfer(address recipient, uint256 amount) external nonReentrant {
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(amount <= balanceOf(msg.sender), "Not enough tokens");

        uint256 feeAmount = (amount * FEE_RATE) / 10000; // Calculate the fee amount (2.5% of the transfer amount)
        uint256 transferAmount = amount - feeAmount; // Calculate the transfer amount after deducting the fee

        _transfer(msg.sender, recipient, transferAmount); // Transfer the tokens to the recipient
        _transfer(msg.sender, steeloAddress, feeAmount); // Transfer the fee to the steeloAddress
    }

    // Unified minting function
    function steeloMint (uint256 _steezTransactions, uint256 _currentPrice) external onlyOwner nonReentrant {
        require(totalSupply() > TGE_AMOUNT, "steeloMint can only be called after the TGE");
        require(_steezTransactions > 0, "_steezTransactions must be greater than 0");
        require(_currentPrice > 0, "_currentPrice must be greater than 0");
        
        uint256 mintAmount = calculateMintAmount(_steezTransactions, _currentPrice);
        distributeMintedTokens(mintAmount);
    }

    // Calculates the amount to mint based on transaction count and current price
    function calculateMintAmount(uint256 _steezTransactions, uint256 _currentPrice) public view returns (uint256) {
        uint256 adjustmentFactor = 1 ether;
        if (_currentPrice >= pMax) {
            adjustmentFactor += (_currentPrice - pMax) * alpha / 100;
        } else if (_currentPrice <= pMin) {
            adjustmentFactor -= (pMin - _currentPrice) * beta / 100;
        }
        uint256 mintAmount = rho * _steezTransactions * adjustmentFactor / 1 ether / 1 ether;
        return mintAmount;
    }

    // Function to calculate the amount to burn based on the burn rate
    function calculateBurnAmount(uint256 amount) private view returns (uint256) {
        return amount * burnRate / 10000; // Assuming burnRate is a percentage of 10000 for precision
    }
    
    // Function to adjust the mint rate, can be called through governance decisions (SIPs)
    function adjustMintRate(uint256 _newMintRate) external onlyOwner nonReentrant {
        require(_newMintRate > 0, "Mint rate must be greater than 0");
        require(_newMintRate <= mintRate * 110 / 100 && _newMintRate >= mintRate * 90 / 100, "New rate must be within 10% of the current rate");

        mintRate = _newMintRate;
        emit MintRateUpdated(_newMintRate);
    }

    // Function to adjust the burn rate, can be called through governance decisions (SIPs)
    function adjustBurnRate(uint256 _newBurnRate) external onlyOwner nonReentrant {
        require(_newBurnRate > 0, "Burn rate must be greater than 0");
        require(_newBurnRate <= burnRate * 110 / 100 && _newBurnRate >= burnRate * 90 / 100, "New rate must be within 10% of the current rate");

        burnRate = _newBurnRate;
        emit BurnRateUpdated(_newBurnRate);
    }
    
    // Burn tokens to implement deflationary mechanism
    function burnTokens() private {
        uint256 treasuryBalance = _balanceOf(address(this));
        uint256 burnAmount = (treasuryBalance * FEE_RATE / 1000) * burnRate / 100;

        require(treasuryBalance >= burnAmount, "Not enough tokens to burn");
        require(burnAmount > 0, "Burn amount must be greater than 0");
        
        _burn(burnAmount);
        totalBurned += burnAmount;
        lastBurnUpdate = block.timestamp;

        emit TokensBurned(burnAmount);
    }

    // Function to get the owner's address
    function getOwner() public view returns (address) {
        return owner();
    }

    // Function to update the transaction count and possibly trigger burning
    function updateSteezTransactionCount(uint256 mintAmount) external onlyOwner nonReentrant {
        steezTransactionCount += mintAmount;
        if (!isDeflationary && steezTransactionCount > 0) {
        isDeflationary = true;
        }
        if (steezTransactionCount >= BURN_THRESHOLD) {
            burnTokens();
        }
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
        req.add("path", "volume"); // Specify the JSON path that leads to the data of interest
        return sendChainlinkRequestTo(0xb83E47C2bC239B3bf370bc41e1459A34b41238D0, request, fee);
    }

    // Function to receive the response from the Chainlink oracle
    function fulfill(bytes32 _requestId, uint256 _steezTransactionCount) public recordChainlinkFulfillment(_requestId) {
        steezTransactionCount = _steezTransactionCount;
        checkForMintOrBurn();
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