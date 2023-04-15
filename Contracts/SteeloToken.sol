//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "node_modules/@safe-global/safe-core-sdk";
import "node_modules/@safe-global/safe-contracts/contracts/Safe.sol";
import "node_modules/@safe-global/safe-contracts/contracts/proxies/SafeProxy.sol"; 

contract SteeloToken is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

    // Constants
    uint256 private constant INITIAL_CAP = 500;
    uint256 private constant TRANSACTION_MULTIPLIER = 2;
    uint256 private constant PRE_ORDER_MINIMUM_SOLD = 125; // 50% of 250

    // State Variables
    uint256 private _maxCreatorTokens;
    string private _baseURI;
    Counters.Counter private _currentTokenID;
    mapping(uint256 => uint256) private _totalSupply;
    mapping(uint256 => uint256) private _transactionCount;
    mapping(uint256 => address) private _creator;
    mapping(uint256 => uint256) private _royalty;
    mapping(uint256 => mapping(address => uint256)) private _undistributedRoyalties;
    mapping(uint256 => uint256) private _mintedInLastYear;
    mapping(uint256 => uint256) private _lastMintTime;
    mapping(uint256 => uint256) private _lastSnapshot;
    uint256 private _lastSnapshotTimestamp;
    mapping(uint256 => mapping(address => uint256)) private _snapshotBalances;
    uint256 private _snapshotCounter;
    mapping(address => bool) private _hasCreatedToken;

    // Royalties
    uint256 private constant TOKEN_CREATOR_ROYALTY = 50; // 5%
    uint256 private constant STEELO_ROYALTY = 25; // 2.5%
    uint256 private constant HOLDER_ROYALTY = 25; // 2.5%

    // Events
    event TokenMinted(uint256 indexed tokenId, address indexed creator, uint256 totalSupply);
    event AnnualTokenIncrease(uint256 indexed tokenId);
    event RoyaltyUpdated(uint256 indexed tokenId, address indexed user, uint256 updatedRoyaltyAmount);
    event TokenBurned(uint256 indexed tokenId, address indexed owner);

    // Modifiers
    modifier dailySnapshot() {
        if (block.timestamp >= _lastSnapshotTimestamp.add(1 days)) {
            _takeSnapshot();
            _lastSnapshotTimestamp = block.timestamp;
        }
        _;
    }

    modifier canCreateToken(address creator) {
        require(!_hasCreatedToken[creator], "SteeloToken: Creator has already created a token.");
        _;
    }

    // Add the following contract addresses
    address private constant GNOSIS_SAFE_MASTER_COPY = 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F; // Mainnet Gnosis Safe Master Copy address. Update it based on your network.
    address private constant GNOSIS_SAFE_PROXY_FACTORY = 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F48; // Mainnet Gnosis Safe Proxy Factory address. Update it based on your network.

    // Functions

        // Initialize With Safe-Global's MultiSig Wallet
        function initializeWithSafe(string memory baseURI, address safeAddress) public initializer {
            __ERC1155_init("https://myapi.com/api/token/{id}.json");
            __Ownable_init_unchained(safeAddress);
            __Pausable_init_unchained();

            _baseURI = baseURI;

            // Gnosis Safe multisig setup
            GnosisSafeProxyFactory proxyFactory = GnosisSafeProxyFactory(GNOSIS_SAFE_PROXY_FACTORY);
            GnosisSafeProxy proxy = GnosisSafeProxy(proxyFactory.createProxy(GNOSIS_SAFE_MASTER_COPY, ""));
            ISafe safe = ISafe(address(proxy));
            
            // Configure the Gnosis Safe with the given `safeAddress`
            safe.setup(
                new address[](1){safeAddress}, // The Safe owners
                1,                             // The number of required confirmations
                address(0),                    // Address of the module that checks signatures
                bytes(""),                     // Data for the module that checks signatures
                address(0),                    // Address of the fallback handler
                address(0),                    // Address of the token payment receiver
                0,                             // Value of the token payment
                address(0)                     // Address of the token to pay
            );
            
            // Transfer ownership of the contract to the Gnosis Safe
            transferOwnership(address(safe));
        }

        // Set the maximum allowed tokens for a creator
        function setMaxCreatorTokens(uint256 maxTokens) public onlyOwner {
            _maxCreatorTokens = maxTokens;
        }

        // Get the maximum allowed tokens for a creator
        function getMaxCreatorTokens() public view returns (uint256) {
            return _maxCreatorTokens;
        }

        // Set the base URI
        function setBaseURI(string memory newBaseURI) public onlyOwner {
            _baseURI = newBaseURI;
            emit BaseURIUpdated(newBaseURI);
        }

        // Get the base URI
        function baseURI() public view returns (string memory) {
            return _baseURI;
        }

        // Override _beforeTokenTransfer() from ERC1155Upgradeable.sol
        function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
            internal
            whenNotPaused
            override
        {
            super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        }

        // Create token
        function createToken() public onlyOwner {
            require(_creator[msg.sender] == false, "SteeloToken: Creator has already created a token.");
            _creator[msg.sender] = true;

            _currentTokenID.increment();
            uint256 newTokenId = _currentTokenID.current();

            emit TokenCreated(newTokenId, msg.sender);
        }

        // Pre-order function
        function preOrder(uint256 tokenId, uint256 amount) public payable onlyOwner {
            require(_totalSupply[tokenId] == 0, "SteeloToken: Pre-order has already been completed.");

            // Check for pre-order eligibility
            uint256 minTokenAmount = MAX_CREATOR_TOKENS.div(2);
            require(amount >= minTokenAmount, "SteeloToken: Minimum pre-order amount not reached.");

            // Mint pre-ordered tokens
            _mint(msg.sender, tokenId, amount, "");
            _totalSupply[tokenId] = amount;

            emit PreOrderMinted(tokenId, msg.sender, amount);
        }

        // Launch token function
        function launchToken(uint256 tokenId, uint256 amount) public payable onlyOwner {
            require(_totalSupply[tokenId] > 0, "SteeloToken: Pre-order must be completed first.");
            require(_totalSupply[tokenId].add(amount) <= MAX_CREATOR_TOKENS, "SteeloToken: Maximum cap exceeded.");

            // Mint launched tokens
            _mint(msg.sender, tokenId, amount, "");
            _totalSupply[tokenId] = _totalSupply[tokenId].add(amount);

            emit TokenLaunched(tokenId, msg.sender, _totalSupply[tokenId]);
        }

        // Burn token
        function burn(uint256 tokenId, uint256 amount) public onlyOwner {
            require(amount <= balanceOf(msg.sender, tokenId), "SteeloToken: Insufficient balance to burn.");
            _burn(msg.sender, tokenId, amount);
        }

        // Snapshot function
        function _takeSnapshot() internal {
            _snapshotCounter = _snapshotCounter.add(1);

            for (uint256 tokenId = 1; tokenId <= _currentTokenID.current(); tokenId++) {
                _snapshotBalances[_snapshotCounter][tokenId] = _totalSupply[tokenId];
            }
        }

        // Transfer With Royalty function
        function transferWithRoyalty(
            address from,
            address to,
            uint256 tokenId,
            uint256 amount
        ) public dailySnapshot {
            _transferWithRoyalty(from, to, tokenId, amount);
        }

        // Minting function
        function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) public onlyOwner dailySnapshot {
            require(_currentTokenID.current() < type(uint256).max, "SteeloToken: TokenID overflow");
            require(_totalSupply[tokenId] < MAX_CREATOR_TOKENS, "SteeloToken: Maximum cap reached");

            // Mint the tokens
            _mint(to, tokenId, amount, data);
            _totalSupply[tokenId] = _totalSupply[tokenId].add(amount);

            // Set token creator and royalty
            if (_creator[tokenId] == address(0)) {
                _creator[tokenId] = to;
                _royalty[tokenId] = TOKEN_CREATOR_ROYALTY.add(STEELO_ROYALTY).add(HOLDER_ROYALTY);
            
            // Take a snapshot after minting tokens
            _takeSnapshot();

            emit TokenMinted(tokenId, to, _totalSupply[tokenId]);
        }

        // Update the transaction count
        _transactionCount[tokenId] = _transactionCount[tokenId].add(amount);

        // Update the minting state for annual token increase
        if (_mintedInLastYear[tokenId].add(amount) <= INITIAL_CAP.mul(TRANSACTION_MULTIPLIER)) {
            _mintedInLastYear[tokenId] = _mintedInLastYear[tokenId].add(amount);
            _lastMintTime[tokenId] = block.timestamp;
        }

        emit TokenMinted(tokenId, to, _totalSupply[tokenId]);
        }

        function uri(uint256 tokenId) public view override returns (string memory) {
                return string(abi.encodePacked(_baseURI, tokenId.toString(), ".json"));
    }

        function totalSupply(uint256 tokenId) public view returns (uint256) {
            return _totalSupply[tokenId];
        }

        function tokenCreator(uint256 tokenId) public view returns (address) {
            return _creator[tokenId];
        }

        function royalty(uint256 tokenId) public view returns (uint256) {
            return _royalty[tokenId];
        }

        function transactionCount(uint256 tokenId) public view returns (uint256) {
            return _transactionCount[tokenId];
        }

        function mintedInLastYear(uint256 tokenId) public view returns (uint256) {
            return _mintedInLastYear[tokenId];
        }

        function lastMintTime(uint256 tokenId) public view returns (uint256) {
            return _lastMintTime[tokenId];
        }

        function _takeSnapshot(/* parameters */) internal {
            // Snapshot logic
        }

        function expansionEligible(uint256 tokenId) public view returns (bool) {
            return _transactionCount[tokenId] >= _totalSupply[tokenId].mul(2);
        }

        // Additional functions for token management, like Semi-fungible tokens, Hooks, Upgrading, batchTransfer, batchBalance, safeBatchTransferFrom, etc.
        // Optional functions such as approve, allowance, isApprovedForAll, setApprovalForAll

        // Annual token increase eligibility check
        function checkAnnualTokenIncrease(uint256 tokenId) public view returns (bool) {
            return (block.timestamp >= _lastMintTime[tokenId].add(365 days)) &&
                (_transactionCount[tokenId] >= _totalSupply[tokenId].mul(TRANSACTION_MULTIPLIER));
        }

        // Function to initiate the annual token increase process
        function initiateAnnualTokenIncrease(uint256 tokenId) external {
            require(checkAnnualTokenIncrease(tokenId), "SteeloToken: Token not eligible for increase");
            _lastMintTime[tokenId] = block.timestamp;

            emit AnnualTokenIncrease(tokenId);
        }

        // Custom transfer function for royalty distribution
        function transferWithRoyalty(
            address from,
            address to,
            uint256 tokenId,
            uint256 amount
        ) public dailySnapshot {
            _transferWithRoyalty(from, to, tokenId, amount);
        }

            function _distributeCommunityRoyalty(
                uint256 tokenId,
                uint256 communityRoyalty
            ) internal {
                uint256 totalSnapshotSupply = _snapshotBalances[_snapshotCounter][tokenId];
                uint256 royaltyPerToken = communityRoyalty.div(totalSnapshotSupply);

                for (uint256 i = 1; i <= _currentTokenID.current(); i++) {
                    _undistributedRoyalties[i][tokenId] = _undistributedRoyalties[i][tokenId].add(royaltyPerToken);
                }
            }

        function claimRoyalty(uint256 tokenId) external {
            uint256 userRoyalty = _undistributedRoyalties[tokenId][msg.sender];
            require(userRoyalty > 0, "SteeloToken: No royalty available for the caller.");

            _undistributedRoyalties[tokenId][msg.sender] = 0;
            _safeTransferFrom(address(this), msg.sender, tokenId, userRoyalty, "");
        }

        function _transferWithRoyalty(
            address from,
            address to,
            uint256 tokenId,
            uint256 amount
        ) internal {
            uint256 sellerAmount = amount.mul(900).div(1000);
            uint256 creatorRoyalty = amount.mul(50).div(1000);
            uint256 steeloRoyalty = amount.mul(20).div(1000);
            uint256 communityRoyalty = amount.mul(30).div(1000);

            // Transfer royalties
            _safeTransferFrom(from, _creator[tokenId], tokenId, creatorRoyalty, "");
            _safeTransferFrom(from, address(this), tokenId, steeloRoyalty, "");

            // Distribute community royalty
            _distributeCommunityRoyalty(tokenId, communityRoyalty);

            // Transfer remaining tokens
            _safeTransferFrom(from, to, tokenId, sellerAmount, "");
        }

        // User Royalty View from last Snapshot
        function getRoyaltyFromLastSnapshot(uint256 tokenId, address user) public view returns (uint256) {
            uint256 userRoyalty = _undistributedRoyalties[tokenId][user];
            return userRoyalty;
        }

        function updateRoyalty(uint256 tokenId) public {
            // Update royalty calculation logic based on transfers since the last snapshot
            // You can either store recent transfer details in the contract itself, or use an external source like a subgraph or events
            // ...

            // Update the user's _undistributedRoyalties
            _undistributedRoyalties[tokenId][msg.sender] = updatedRoyaltyAmount;

            // Emit an event to notify the dApp that the user's royalty has been updated
            emit RoyaltyUpdated(tokenId, msg.sender, updatedRoyaltyAmount);
        }
}