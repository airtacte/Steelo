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

contract CreatorToken is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

    // Constants
    uint256 private constant INITIAL_CAP = 500;
    uint256 private constant TRANSACTION_MULTIPLIER = 2;
    uint256 private constant PRE_ORDER_MINIMUM_SOLD = 125; // 50% of 250

    uint256 private constant TOKEN_CREATOR_ROYALTY = 50; // 5%
    uint256 private constant STEELO_ROYALTY = 25; // 2.5%
    uint256 private constant HOLDER_ROYALTY = 25; // 2.5%

    // Variables
    string private _baseURI;
    uint256 private _maxCreatorTokens;
    uint256 private _transactionFee;
    mapping(address => bool) private _hasCreatedToken;
    mapping(uint256 => bool) private _tokenExists; 
    mapping(address => bool) private _creator;
    mapping(uint256 => uint256) private _totalSupply;
    mapping(uint256 => address) private _royaltyReceiver;
    mapping(uint256 => uint256) private _royalty;
    mapping(address => uint256) private _shareholdings;
    uint256 private _totalShareholdings;
    mapping(uint256 => mapping(address => uint256)) private _undistributedRoyalties;
    mapping(uint256 => uint256) private _transactionCount;
    mapping(uint256 => uint256) private _mintedInLastYear;
    mapping(uint256 => uint256) private _lastMintTime;

    // Counters
    CountersUpgradeable.Counter private _currentTokenID;
    CountersUpgradeable.Counter private _snapshotCounter;

    // Snapshots
    mapping(uint256 => mapping(uint256 => uint256)) private _snapshotBalances;
    uint256 private _lastSnapshotTimestamp;
    uint256 private _snapshotCounter;
    mapping(uint256 => uint256) private _lastSnapshot;

    // Events
    event TokenMinted(uint256 indexed tokenId, address indexed creator, uint256 amount);
    event TokenLaunched(uint256 indexed tokenId, address indexed launcher, uint256 totalSupply);
    event PreOrderMinted(uint256 indexed tokenId, address indexed buyer, uint256 amount);
    event RoyaltyUpdated(uint256 indexed tokenId, address indexed user, uint256 updatedRoyaltyAmount);
    event TokenBurned(uint256 indexed tokenId, address indexed burner, uint256 amount);
    event AnnualTokenIncrease(uint256 indexed tokenId);

    // Modifiers
    modifier onlyCreator() {
        require(_shareholdings[msg.sender] > 0, "CreatorToken: Caller is not a creator");
        _;
    }

    modifier canCreateToken(address creator) {
        require(!_hasCreatedToken[creator], "CreatorToken: Creator has already created a token.");
        _;
    }

    modifier dailySnapshot() {
        if (block.timestamp >= _lastSnapshotTimestamp.add(1 days)) {
            _takeSnapshot();
            _lastSnapshotTimestamp = block.timestamp;
        }
        _;
    }

    // Add the following contract addresses
    address private constant GNOSIS_SAFE_MASTER_COPY = 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F; // Mainnet Gnosis Safe Master Copy address. Update it based on your network.
    address private constant GNOSIS_SAFE_PROXY_FACTORY = 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F48; // Mainnet Gnosis Safe Proxy Factory address. Update it based on your network.
    address private _safeAddress; // Store the address of a Gnosis Safe

    // Functions

        // Initialize With Safe-Global's MultiSig Wallet
        function initialize(string memory baseURI, uint256 maxCreatorTokens, uint256 transactionFee) public initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init();
        __Pausable_init();

        _baseURI = baseURI;
        _maxCreatorTokens = maxCreatorTokens;
        _transactionFee = transactionFee;

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

        // Create custom creator token
        function createToken() public {
            require(!_creator[msg.sender], "CreatorToken: Creator has already created a token.");
            _creator[msg.sender] = true;

            _currentTokenID.increment();
            uint256 newTokenId = _currentTokenID.current();

            _royaltyReceiver[newTokenId] = msg.sender;
            _royalty[newTokenId] = TOKEN_CREATOR_ROYALTY;

            emit TokenMinted(newTokenId, msg.sender, 1);
        }

        // Pre-order function
        function preOrder(uint256 tokenId, uint256 amount) public payable {
            require(_creator[msg.sender], "CreatorToken: Only creators can pre-order tokens.");
            require(_totalSupply[tokenId] == 0, "CreatorToken: Pre-order has already been completed.");
            require(amount >= PRE_ORDER_MINIMUM_SOLD, "CreatorToken: Minimum pre-order amount not reached.");

            _mint(msg.sender, tokenId, amount, "");
            _totalSupply[tokenId] = amount;

            emit PreOrderMinted(tokenId, msg.sender, amount);
        }

        // Launch token function
        function launchToken(uint256 tokenId, uint256 amount) public payable {
            require(_creator[msg.sender], "CreatorToken: Only creators can launch tokens.");
            require(_totalSupply[tokenId] > 0, "CreatorToken: Pre-order must be completed first.");
            require(_totalSupply[tokenId].add(amount) <= _maxCreatorTokens, "CreatorToken: Maximum cap exceeded.");

            _mint(msg.sender, tokenId, amount, "");
            _totalSupply[tokenId] = _totalSupply[tokenId].add(amount);

            emit TokenLaunched(tokenId, msg.sender, _totalSupply[tokenId]);
        }

        // Expansion function
        function expandToken(uint256 tokenId, uint256 amount) external payable onlyCreator {
            require(_totalSupply[tokenId] > 0, "CreatorToken: Token does not exist");
            require(_totalSupply[tokenId].add(amount) <= _maxCreatorTokens, "CreatorToken: Maximum cap exceeded");

            _mint(msg.sender, tokenId, amount, "");
            _totalSupply[tokenId] = _totalSupply[tokenId].add(amount);

            emit TokenMinted(tokenId, msg.sender, amount);
        }

        // Update royalty function
        function updateRoyalty(uint256 tokenId, address user, uint256 amount) external onlyCreator {
            require(_creator[tokenId] == msg.sender, "CreatorToken: Caller is not the creator of the token");
            require(_tokenExists[tokenId], "CreatorToken: Token does not exist");

            _undistributedRoyalties[tokenId][user] = _undistributedRoyalties[tokenId][user].add(amount);

            emit RoyaltyUpdated(tokenId, user, amount);
        }

        // Update transaction fee function
        function updateTransactionFee(uint256 transactionFee) external onlyOwner {
            require(transactionFee <= 100, "CreatorToken: Transaction fee cannot exceed 100%");
            _transactionFee = transactionFee;

            emit TransactionFeeUpdated(transactionFee);
        }

        // Burn token
        function burn(uint256 tokenId, uint256 amount) public {
            require(balanceOf(msg.sender, tokenId) >= amount, "CreatorToken: Not enough tokens to burn.");

            _burn(msg.sender, tokenId, amount);

            emit TokenBurned(tokenId, msg.sender, amount);
        }

        // Get royalty receiver for a token
        function getRoyaltyReceiver(uint256 tokenId) public view returns (address) {
            return _royaltyReceiver[tokenId];
        }

        // Get royalty percentage for a token
        function getRoyaltyPercentage(uint256 tokenId) public view returns (uint256) {
            return _royalty[tokenId];
        }

        // Update royalty receiver for a token
        function updateRoyaltyReceiver(uint256 tokenId, address newReceiver) public {
            require(_creator[msg.sender], "CreatorToken: Only creators can update royalty receiver.");
            require(newReceiver != address(0), "CreatorToken: Royalty receiver cannot be zero address.");

            _royaltyReceiver[tokenId] = newReceiver;
        }

        // Update royalty percentage for a token
        function updateRoyaltyPercentage(uint256 tokenId, uint256 newPercentage) public {
            require(_creator[msg.sender], "CreatorToken: Only creators can update royalty percentage.");
            require(newPercentage <= 100, "CreatorToken: Royalty percentage cannot be greater than 100.");

            _royalty[tokenId] = newPercentage;
        }

        // Override uri function from ERC1155Upgradeable.sol
        function uri(uint256 tokenId) public view override returns (string memory) {
            return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenId.toString())) : "";
        }

        // Pause contract
        function pause() public onlyOwner {
            _pause();
        }

        // Unpause contract
        function unpause() public onlyOwner {
            _unpause();
        }

        // Withdraw transaction fee
        function withdraw() public onlyOwner {
            payable(owner()).transfer(address(this).balance);
        }

        // Fallback function
        receive() external payable {}

        // Destroy contract
        function destroy() public onlyOwner {
            selfdestruct(payable(owner()));
        }

        // Snapshot function
        function _takeSnapshot() internal {
            _snapshotCounter = _snapshotCounter.add(1);

            for (uint256 tokenId = 1; tokenId <= _currentTokenID.current(); tokenId++) {
                _snapshotBalances[_snapshotCounter][tokenId] = _totalSupply[tokenId];
            }
        }

        // Minting function
        function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) public onlyOwner dailySnapshot {
            require(_currentTokenID.current() < type(uint256).max, "CreatorToken: TokenID overflow");
            require(_totalSupply[tokenId] < MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap reached");

            // Mint the tokens
            function _mint(address to, uint256 tokenId, uint256 amount) internal {
                require(to != address(0), "CreatorToken: Cannot mint to zero address");
                require(amount > 0, "CreatorToken: Cannot mint zero amount");

                _balances[tokenId][to] += amount;
                emit TransferSingle(msg.sender, address(0), to, tokenId, amount);

                if (!_tokenExists[tokenId]) {
                    _tokenExists[tokenId] = true;
                    emit TokenMinted(tokenId, msg.sender, amount);
                }
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
            require(checkAnnualTokenIncrease(tokenId), "CreatorToken: Token not eligible for increase");
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

        function claimRoyalty(uint256 tokenId) external {
            require(_tokenExists[tokenId], "CreatorToken: Token does not exist");
            require(_undistributedRoyalties[tokenId][msg.sender] > 0, "CreatorToken: No royalty available for the caller");

            uint256 userRoyalty = _undistributedRoyalties[tokenId][msg.sender];
            _undistributedRoyalties[tokenId][msg.sender] = 0;

            try IERC1155(address(this)).safeTransferFrom(address(this), msg.sender, tokenId, userRoyalty, "") {
                emit TransferSingle(address(this), msg.sender, address(0), tokenId, userRoyalty);
            } catch Error(string memory error) {
                revert(string(abi.encodePacked("CreatorToken: Error transferring royalty - ", error)));
            } catch {
                revert("CreatorToken: Unknown error transferring royalty");
            }
        }

        // User Royalty View from last Snapshot
        function getRoyaltyFromLastSnapshot(uint256 tokenId, address user) public view returns (uint256) {
            require(_tokenExists[tokenId], "CreatorToken: Token does not exist");
            require(user != address(0), "CreatorToken: Cannot get royalty for zero address");

            uint256 userRoyalty = _undistributedRoyalties[tokenId][user];
            return userRoyalty;
        }

        function updateRoyalty(uint256 tokenId) public {
            // Get the current balance of the contract's token
            uint256 currentBalance = IERC721(address(this)).balanceOf(address(this));

            // Calculate the total amount of tokens transferred since the last snapshot
            uint256 tokensTransferred = currentBalance - _lastSnapshotBalance[tokenId];

            // Calculate the total amount of transaction fees generated by the transferred tokens
            uint256 transactionFees = tokensTransferred * _transactionFeeRate[tokenId] / 10000;

            // Calculate the updated royalty amount for each user
            for (uint256 i = 0; i < _tokenHolders[tokenId].length; i++) {
                address user = _tokenHolders[tokenId][i];
                uint256 userShare = _userShares[tokenId][user];
                uint256 userRoyalty = transactionFees * userShare / 10000;
                _undistributedRoyalties[tokenId][user] += userRoyalty;
            }

            // Update the last snapshot balance to the current balance
            _lastSnapshotBalance[tokenId] = currentBalance;

            // Emit an event to notify the dApp that the user's royalty has been updated
            emit RoyaltyUpdated(tokenId, msg.sender, _undistributedRoyalties[tokenId][msg.sender]);
        }
}