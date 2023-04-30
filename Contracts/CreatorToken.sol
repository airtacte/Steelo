// SPDX-License-Identifier: MIT
// contracts/DiamondCutFacet.sol
pragma solidity ^0.8.19;

import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts/utils/Address.sol";
import "node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "node_modules/@openzeppelin/contracts/token/ERC2535/IDiamondCut.sol";
import "node_modules/@safe-global/safe-core-sdk";
import "node_modules/@safe-global/safe-contracts/contracts/Safe.sol";
import "node_modules/@safe-global/safe-contracts/contracts/proxies/SafeProxy.sol"; 
import "./Royalties.sol";

contract CreatorToken is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

    // Returns array for the functions to be added as facts to the diamond contract
    function getSelectors() public pure returns (bytes4[] memory) {
        return [
            this.createToken.selector, // Add more function selectors as needed
            this.manageToken.selector
        ];
    }

    // ROLES
    mapping (address => bool) private admins;
    mapping (address => bool) private creators;
    mapping (address => bool) private owners;
    mapping (address => bool) private users;

    // CONSTANTS
    uint256 private constant INITIAL_CAP = 500;
    uint256 private constant TRANSACTION_MULTIPLIER = 2;
    uint256 private constant PRE_ORDER_MINIMUM_SOLD = 125; // 50% of 250

    Royalties private _royalties;

    // VARIABLES
    string private _baseURI;
    uint256 private _maxCreatorTokens;
    uint256 private _transactionFee;
    uint256 private _totalShareholdings;
    mapping(address => bool) private _hasCreatedToken;
    mapping(uint256 => bool) private _tokenExists; 
    mapping(uint256 => uint256) private _totalSupply;
    mapping(address => uint256) private _shareholdings;
    mapping(uint256 => uint256) private _transactionCount;
    mapping(uint256 => uint256) private _mintedInLastYear;
    mapping(uint256 => uint256) private _lastMintTime;

    // SNAPSHOTS
    CountersUpgradeable.Counter private _currentTokenID;
    CountersUpgradeable.Counter private _snapshotCounter;
    mapping(uint256 => mapping(uint256 => uint256)) private _snapshotBalances;
    mapping(uint256 => uint256) private _lastSnapshot;
    uint256 private _lastSnapshotTimestamp;
    uint256 private _snapshotCounter;

    // EVENTS
    event TokenMinted(uint256 indexed tokenId, address indexed creator, uint256 amount);
    event PreOrderMinted(uint256 indexed tokenId, address indexed buyer, uint256 amount);
    event TokenLaunched(uint256 indexed tokenId, address indexed launcher, uint256 totalSupply);
    event RoyaltyUpdated(uint256 indexed tokenId, address indexed user, uint256 updatedRoyaltyAmount);
    event AnnualTokenIncrease(uint256 indexed tokenId);
    event RoyaltySet(uint256 indexed tokenId, uint256 royalty);
    event RoyaltyPaid(uint256 indexed tokenId, address indexed payee, uint256 amount);
    event CreatorRoyaltyTransferred(address indexed from, address indexed to, uint256 indexed tokenId, uint256 value);
    event SteeloRoyaltyTransferred(address indexed from, address indexed to, uint256 indexed tokenId, uint256 value);
    event CommunityRoyaltyTransferred(address indexed from, address indexed to, uint256 indexed tokenId, uint256 value);
    event TransactionFeeUpdated(uint256 transactionFee);
    event TokenTransferred(uint256 tokenId, address from, address to, uint256 amount);
    event TokenBurned(uint256 tokenId, address owner, uint256 amount);
    event RoyaltyUpdated(uint256 tokenId, address user, uint256 amount);

    // MODIFIERS
    modifier canCreateToken(address creator) {require(!_hasCreatedToken[creator], "CreatorToken: Creator has already created a token."); _;}
    modifier onlyAdmin() {require(admins[msg.sender], "Only Admin can call this function"); _;}
    modifier onlyCreator() {require(creatorToIsAdmin[msg.sender] == false && msg.sender != creator, "CreatorToken: Only Creators can call this function"); _;}
    modifier onlyOwner() {require(creatorToIsAdmin[msg.sender] == false && msg.sender != creator && msg.sender != owner(), "CreatorToken: Only Owners can call this function"); _;}
    modifier onlyUser() {require(users[msg.sender], "Only User can call this function"); _;}
    modifier onlyCreatorOrOwner() {require(owners[msg.sender] || creators[msg.sender], "CreatorToken: Only Creators or Owners can call this function"); _;}
    modifier dailySnapshot() {if (block.timestamp >= _lastSnapshotTimestamp.add(1 days)) {_takeSnapshot(); _lastSnapshotTimestamp = block.timestamp;} _;}
    
    // SAFE GLOBAL (PREVIOUSLY GNOSIS SAFE) CONTRACT ADDRESSES
    address private constant GNOSIS_SAFE_MASTER_COPY = 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F;
    address private constant GNOSIS_SAFE_PROXY_FACTORY = 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F48;
    address public constant STEELO_WALLET = 0x1234567890123456789012345678901234567890; // Placeholder address
    address private _safeAddress;

    // FUNCTIONS
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
                1,          // The number of required confirmations
                address(0), // Address of the module that checks signatures
                bytes(""),  // Data for the module that checks signatures
                address(0), // Address of the fallback handler
                address(0), // Address of the token payment receiver
                0,          // Value of the token payment
                address(0)  // Address of the token to pay
            );
            
            // Transfer ownership of the contract to the Gnosis Safe
            transferOwnership(address(safe));
        }

        // Set Royalties via reference to the Royalties.sol contract
        function setRoyaltiesContract(address royaltiesContractAddress) external onlyOwner {
            require(royaltiesContractAddress != address(0), "CreatorToken: Royalties contract address cannot be zero address.");
            _royalties = Royalties(royaltiesContractAddress);
        }

    // ACCESS CONTROL 

        // Add/Remove Admin Role
        function addAdmin(address _admin) external onlyOwner {admins[_admin] = true;}
        function removeAdmin(address _admin) external onlyOwner {admins[_admin] = false;}

        // Add/Remove Creator Role
        function addCreator(address _creator) external onlyAdmin {creators[_creator] = true;}
        function removeCreator(address _creator) external onlyAdmin {creators[_creator] = false;}

        // Add/Remove Owner Role
        function addOwner(address _owner) external onlyCreator {owners[_owner] = true;}
        function removeOwner(address _owner) external onlyCreator {owners[_owner] = false;}

        // Add/Remove User Role
        function addUser(address _user) external onlyOwnerOrAdmin {users[_user] = true;}
        function removeUser(address _user) external onlyOwnerOrAdmin {users[_user] = false;}

        // Function to restrict feature access to a role
        function isAdmin(address _admin) external view returns(bool) {return admins[_admin];}
        function isCreator(address _creator) external view returns(bool) {return creators[_creator];}
        function isOwner(address _owner) external view returns(bool) {return owners[_owner];}
        function isUser(address _user) external view returns(bool) {return users[_user];}

    // TOKEN LIMITATIONS

        // Set the maximum allowed tokens for a creator
        function setMaxCreatorTokens(uint256 maxTokens) public onlyOwner {_maxCreatorTokens = maxTokens;}

        // Get the maximum allowed tokens for a creator
        function getMaxCreatorTokens() public view returns (uint256) {return _maxCreatorTokens;}

        // Set the base URI
        function setBaseURI(string memory newBaseURI) public onlyOwner {_baseURI = newBaseURI; emit BaseURIUpdated(newBaseURI);}

        // Get the base URI
        function baseURI() public view returns (string memory) {return _baseURI;}

    // KEY TOKEN TRANSACTION MECHANISMS

        // Transfer ownership to new owner
        function transferOwnership(address newOwner, uint256 tokenId) public {
            require(newOwner != address(0), "CreatorToken: Transfer to zero address");
            require(newOwner != _creator[tokenId], "CreatorToken: Transfer to current owner");

            address currentOwner = ownerOf(tokenId);
            require(currentOwner == msg.sender || _operatorApprovals[currentOwner][msg.sender], "CreatorToken: Transfer caller is not owner nor approved");

            _transfer(currentOwner, newOwner, tokenId);

            if (_balances[tokenId][currentOwner] == 0) {
                _removeTokenHolder(tokenId, currentOwner);
            }

            if (_balances[tokenId][newOwner] > 0) {
                _addTokenHolder(tokenId, newOwner);
            }
        }

        // Transfer token balance to specified address
        function transferToken(address to, uint256 tokenId) public {
            require(to != address(0), "CreatorToken: Transfer to zero address");

            address currentOwner = ownerOf(tokenId);
            require(currentOwner == msg.sender || _operatorApprovals[currentOwner][msg.sender], "CreatorToken: Transfer caller is not owner nor approved");

            // Check that the recipient is not the creator of the token
            address tokenCreator = _tokenCreator[tokenId];
            bool isCreator = tokenCreator == currentOwner && !(_balances[tokenId][currentOwner] > 0);
                // Admins also cannot buy creator tokens
            require(to != tokenCreator, "CreatorToken: Creator cannot buy their own token");

            if (_isOwner(currentOwner)) {
                // Transfer to an owner, don't add the Owner role to the recipient
                _transfer(currentOwner, to, tokenId);
            } else {
                // Transfer to a user, add the Owner role to the recipient
                _transfer(currentOwner, to, tokenId);
                _addRole(to, ROLE_OWNER);
            }

            if (_balances[tokenId][currentOwner] == 0) {
                _removeTokenHolder(tokenId, currentOwner);
            }

            if (_balances[tokenId][to] > 0) {
                _addTokenHolder(tokenId, to);
            }
        }

        // Create custom creator token
        function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) public onlyOwner dailySnapshot {
            require(!_exists(tokenId), "CreatorToken: token already exists");
            require(to != address(0), "CreatorToken: Cannot mint to zero address");
            require(_currentTokenID.current() < type(uint256).max, "CreatorToken: TokenID overflow");
            require(_totalSupply[tokenId] < MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap reached");
            require(amount > 0, "CreatorToken: Cannot mint zero amount");
            require(to != _creator[tokenId], "CreatorToken: Token creator cannot mint their own tokens");
            require(tokenId != 0, "CreatorToken: Token ID cannot be 0");
            _royalties.mint(to, tokenId, amount);

            uint256 maxAllowedMint = getMaxAllowedMint(msg.sender, tokenId);
            require(amount <= maxAllowedMint, "CreatorToken: Exceeds maximum allowed mint amount");

            // Set token creator and royalty
            if (_creator[tokenId] == address(0)) {
                address tokenCreator = msg.sender;
                _creator[tokenId] = tokenCreator;
                _royalty[tokenId].creatorRoyalty = TOKEN_CREATOR_ROYALTY; // On primary sale, 90% goes to Creator (as the seller)
                _royalty[tokenId].steeloRoyalty = STEELO_ROYALTY;
                _royalty[tokenId].communityRoyalty = COMMUNITY_ROYALTY; // On primary sale, community royalty 100% goes to Steelo
            }

            // Update the transaction count
            _transactionCount[tokenId] = _transactionCount[tokenId].add(amount);

            if (!_tokenExists[tokenId]) {
                _tokenExists[tokenId] = true;
                emit TokenMinted(tokenId, msg.sender, amount);
            }

            // Update the minting state for annual token increase
            if (_mintedInLastYear[tokenId].add(amount) <= INITIAL_CAP.mul(TRANSACTION_MULTIPLIER)) {
                _mintedInLastYear[tokenId] = _mintedInLastYear[tokenId].add(amount);
                _lastMintTime[tokenId] = block.timestamp;
            }

            emit TokenMinted(tokenId, to, _totalSupply[tokenId]);

            // Calculate and distribute royalties
            uint256 value = amount.mul(_royalty[tokenId].price).div(100);
            uint256 creatorFee = value.mul(_royalty[tokenId].creatorRoyalty).div(100);
            uint256 steeloFee = value.mul(_royalty[tokenId].steeloRoyalty).div(100);
            uint256 communityFee = value.mul(_royalty[tokenId].communityRoyalty).div(100);
            _balances[tokenId][to] = _balances[tokenId][to].add(amount);
            _balances[tokenId][msg.sender] = _balances[tokenId][msg.sender].add(creatorFee);
            _balances[tokenId][STEELO_WALLET] = _balances[tokenId][STEELO_WALLET].add(steeloFee);
            if (totalSupply(tokenId) > 1) {
                address[] memory holders = _getNonZeroHolders(tokenId);
                for (uint256 i = 0; i < holders.length; i++) {
                    address holder = holders[i];
                    uint256 share = _balances[tokenId][holder].mul(100).div(totalSupply(tokenId).sub(amount));
                    if (holder != tokenCreator) { //exclude token creator if they own the token
                        uint256 communityRoyalty = communityFee.mul(share).div(100);
                        _balances[tokenId][holder] = _balances[tokenId][holder].add(communityRoyalty);
                    }
                }
            }

            // Take a snapshot after minting tokens
            _takeSnapshot();
        }

    // TOKEN LIFE CYCLE

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
            require(amount > 0, "CreatorToken: Launch amount must be greater than zero");

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
        function burn(address owner, uint256 tokenId, uint256 amount) public {
            require(balanceOf(msg.sender, tokenId) >= amount, "CreatorToken: Not enough tokens to burn.");
            _royalties.burn(owner, tokenId, amount);

            _burn(msg.sender, tokenId, amount);

            emit TokenBurned(tokenId, msg.sender, amount);
        }

    // TOKEN MANAGEMENT TOOLS

        // Update transaction fees
        function updateTransactionFee(uint256 transactionFee) external onlyOwner {
            require(transactionFee <= 100, "CreatorToken: Transaction fee cannot exceed 100%");
            _royalties.updateTransactionFee(transactionFee);
            emit TransactionFeeUpdated(transactionFee);
        }

        // Get royalty receiver for a token
        function getRoyaltyReceiver(uint256 tokenId) public view returns (address) {
            return _royaltyReceiver[tokenId];
            return _royalties.getRoyaltyReceiver(tokenId);
        }

        // Get royalty percentage for a token
        function getRoyaltyPercentage(uint256 tokenId) public view returns (uint256) {
            return _royalty[tokenId];
            return _royalties.getRoyaltyPercentage(tokenId);
        }

        // Override uri function from ERC1155Upgradeable.sol
        function uri(uint256 tokenId) public view virtual override returns (string memory) {
            return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId)));
            return _royalties.getTokenURI(tokenId);
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

        // Destroy contract // DOUBLE CHECK VS BURN -- REDUNDANT
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
            require(to != address(0), "CreatorToken: Cannot mint to zero address");
            require(amount > 0, "CreatorToken: Cannot mint zero amount");
            _royalties.mint(to, tokenId, amount);

            // Mint the tokens  
            _balances[tokenId][to] += amount;
            emit TransferSingle(msg.sender, address(0), to, tokenId, amount);

                if (!_tokenExists[tokenId]) {
                    _tokenExists[tokenId] = true;
                    emit TokenMinted(tokenId, msg.sender, amount);
                }

                // Set token creator and royalty
                if (_creator[tokenId] == address(0)) {
                _creator[tokenId] = to;
                _royalty[tokenId].creatorRoyalty = TOKEN_CREATOR_ROYALTY;
                _royalty[tokenId].steeloRoyalty = STEELO_ROYALTY;
                _royalty[tokenId].communityRoyalty = COMMUNITY_ROYALTY;
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
            
            // Take a snapshot after minting tokens
            _takeSnapshot();
        }
        
        // Additional functions for token management, like Semi-fungible tokens, Hooks, Upgrading, batchTransfer, batchBalance, safeBatchTransferFrom, etc.
        // Optional functions such as approve, allowance, isApprovedForAll, setApprovalForAll

    // TOKEN METADATA

        function totalSupply(uint256 tokenId) public view returns (uint256) {
            return _totalSupply[tokenId];
        }

        function tokenCreator(uint256 tokenId) public view returns (address) {
            return _creator[tokenId];
        }

        // Add token holder
        function _addTokenHolder(uint256 tokenId, address holder) internal {
            _tokenHolders[tokenId].push(holder);
        }

        // Remove token holder
        function _removeTokenHolder(uint256 tokenId, address holder) internal {
            uint256 len = _tokenHolders[tokenId].length;
            for (uint256 i = 0; i < len; i++) {
                if (_tokenHolders[tokenId][i] == holder) {
                    _tokenHolders[tokenId][i] = _tokenHolders[tokenId][len - 1];
                    _tokenHolders[tokenId].pop();
                    break;
                }
            }
        }

        // Get token holders
        function getTokenHolders(uint256 tokenId) public view returns (address[] memory) {
            return _tokenHolders[tokenId];
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

        // Function to check annual token increase eligibility and initiate the process
        function checkAndInitiateAnnualTokenIncrease(uint256 tokenId) public {
            require(_creator[tokenId] == msg.sender, "CreatorToken: Only the token creator can initiate an annual token increase.");
            require(block.timestamp >= _lastTokenIncrease[tokenId].add(ANNUALTOKENINCREASE_DELAY), "CreatorToken: Annual token increase not yet available.");
        
            uint256 currentSupply = _totalSupply[tokenId];
            uint256 newSupply = currentSupply.add(currentSupply.mul(ANNUAL_TOKEN_INCREASE_PERCENTAGE).div(100));
            _totalSupply[tokenId] = newSupply;

            _lastTokenIncrease[tokenId] = block.timestamp;

            emit TokenSupplyIncreased(tokenId, newSupply);

            _initiateAnnualTokenIncrease(tokenId);
        }

        // Custom transfer function for royalty distribution
       function transfer(address from, address to, uint256 tokenId) public {
            require(exists(tokenId), "CreatorToken: Token does not exist.");
            require(isApprovedOrOwner(msg.sender, tokenId), "CreatorToken: Caller is not owner nor approved.");
            require(from != address(0), "CreatorToken: Transfer from zero address.");
            require(to != address(0), "CreatorToken: Transfer to zero address.");
            require(from != to, "CreatorToken: Transfer to self not allowed");
            require(to != address(this), "CreatorToken: Transfer to contract address.");
            require(balance > 0, "CreatorToken: Insufficient balance.");

            _royalties.transfer(from, to, tokenId, amount);
            _royalties.transferWithRoyalty(from, to, tokenId, amount);

            _safeTransferFrom(from, to, tokenId, amount, "");

            uint256 balance = balanceOf(from, tokenId);

            emit TokenTransferred(tokenId, from, to, amount);
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

        // Transfers multiple tokens of different types and amounts to different addresses, while checking for the recipient's ability to receive ERC1155
        function safeBatchTransfer(address[] memory to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) public {
            require(to.length == tokenIds.length && tokenIds.length == amounts.length, "CreatorToken: Arrays length must match");

            for (uint256 i = 0; i < to.length; i++) {
                safeTransfer(to[i], tokenIds[i], amounts[i], data);
            }
        }

        // Transfers multiple tokens of different types and amounts to different addresses, but requires the tokens to be previously approved for safe transfer
        function safeBatchTransferFrom(address from, address[] memory to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) public {
            require(to.length == tokenIds.length && tokenIds.length == amounts.length, "CreatorToken: Arrays length must match");

            for (uint256 i = 0; i < to.length; i++) {
                safeTransferFrom(from, to[i], tokenIds[i], amounts[i], data);
            }
        }

        function _transferWithRoyalty(address from, address to, uint256 tokenId, uint256 amount, bytes memory data) internal {
            require(amount > 0, "CreatorToken: Transfer amount must be greater than zero");

            uint256 creatorRoyalty = _royalty[tokenId].creatorRoyalty;
            uint256 steeloRoyalty = _royalty[tokenId].steeloRoyalty;
            uint256 communityRoyalty = _royalty[tokenId].communityRoyalty;
            uint256 totalRoyalty = creatorRoyalty.add(steeloRoyalty).add(communityRoyalty);
            
            require(totalRoyalty <= amount, "CreatorToken: Royalty exceeds transfer amount");
            require(from != to, "CreatorToken: Transfer to self");

            uint256 sellerAmount = amount.sub(totalRoyalty);

            // Ensure royalties are distributed correctly
            uint256 fromBalance = _balances[tokenId][from];
            require(fromBalance >= amount, "CreatorToken: Insufficient balance");
            uint256 fromBalanceAfterTransfer = fromBalance.sub(amount);
            uint256 undistributedRoyalties = _undistributedRoyalties[tokenId][address(this)].add(communityRoyalty);
            require(fromBalanceAfterTransfer >= undistributedRoyalties, "CreatorToken: Undistributed royalties not accounted for");
            require(sellerAmount > 0, "CreatorToken: Insufficient amount for seller");
            require(creatorRoyalty > 0 || steeloRoyalty > 0 || communityRoyalty > 0, "CreatorToken: No royalties specified");
        
            _balances[tokenId][from] = _balances[tokenId][from].sub(amount, "CreatorToken: Insufficient balance");
            _balances[tokenId][to] = _balances[tokenId][to].add(sellerAmount);
            _balances[tokenId][_creator[tokenId]] = _balances[tokenId][_creator[tokenId]].add(creatorRoyalty);
            _balances[tokenId][address(this)] = _balances[tokenId][address(this)].add(steeloRoyalty);
            _undistributedRoyalties[tokenId][address(this)] = _undistributedRoyalties[tokenId][address(this)].add(communityRoyalty);

            emit TransferWithRoyalty(from, to, tokenId, amount, creatorRoyalty, steeloRoyalty, communityRoyalty, data);

            if (fromBalance == amount) {
                _removeTokenHolder(tokenId, from);
            }

            if (_balances[tokenId][to] == sellerAmount) {
                _addTokenHolder(tokenId, to);
            }

            if (_tokenHolders[tokenId].length < _minTokenHolders[tokenId]) {
                _initiateAnnualTokenIncrease(tokenId);
            }
        }

        function getCommunityRoyaltyShare(address user, uint256 tokenId) public view returns (uint256) {
            uint256 totalSupply = _totalSupply[tokenId];
            uint256 communityRoyalty = _royalty[tokenId].communityRoyalty;

            if (totalSupply == 0 || communityRoyalty == 0) {
                return 0;
            }

            uint256 userBalance = balanceOf(user, tokenId);
            uint256 userShare = communityRoyalty.mul(userBalance).div(totalSupply);

            return userShare;
        }
        
        function getRoyalty(address user, uint256 tokenId) public view returns (uint256) {
            uint256 undistributedRoyalty = _undistributedRoyalties[tokenId][user];
            uint256 totalSupply = _totalSupply[tokenId];
            uint256 balance = balanceOf(user, tokenId);

            if (totalSupply == 0 || balance == 0) {
                return 0;
            }

            uint256 userShare = balance.mul(10000).div(totalSupply);
            uint256 userRoyalty = _royalty[tokenId].creatorRoyalty.mul(userShare).div(10000);

            if (user == _creator[tokenId]) {
                userRoyalty = userRoyalty.add(_royalty[tokenId].creatorRoyalty);
            } else {
                userRoyalty = userRoyalty.add(_royalty[tokenId].steeloRoyalty);
            }

            userRoyalty = userRoyalty.add(undistributedRoyalty);

            return userRoyalty;
        }

        function claimRoyalty(uint256 tokenId) external {
            uint256 userRoyalty = _undistributedRoyalties[tokenId][msg.sender];
            require(userRoyalty > 0, "CreatorToken: No royalty available for the caller.");

            _undistributedRoyalties[tokenId][msg.sender] = 0;
            _safeTransferFrom(address(this), msg.sender, tokenId, userRoyalty, "");
        }

        // Check if the given token exists and returns an array of unique addresses that hold the token
        function getHolders(uint256 tokenId) public view returns (address[] memory) {
            require(_exists(tokenId), "CreatorToken: Token does not exist");
            
            address[] memory holders = new address[](_tokenHolders[tokenId].length());
            for (uint256 i = 0; i < _tokenHolders[tokenId].length(); i++) {
                holders[i] = _tokenHolders[tokenId].at(i);
            }
            
            return holders;
        }
}