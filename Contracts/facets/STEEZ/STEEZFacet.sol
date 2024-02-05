// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts/utils/Address.sol";
import "node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "node_modules/@openzeppelin/contracts/token/ERC2535/IDiamondCut.sol";
import "node_modules/@safe-global/safe-core-sdk";
import "node_modules/@safe-global/safe-contracts/contracts/Safe.sol";
import "node_modules/@safe-global/safe-contracts/contracts/proxies/SafeProxy.sol"; 
import "./SteezFeesFacet.sol";

// WORTH LOOKING INTO EthPM (Ethereum Package Manager)

// CreatorToken.sol is a facet contract that implements the creator token logic and data for the SteeloToken contract
contract STEEZFacet is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable {
    using LibDiamond for LibDiamond.DiamondStorage;
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

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

    // FUNCTIONS
        function initialize(string memory baseURI, uint256 maxCreatorTokens, uint256 transactionFee) public initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init();
        __Pausable_init();

        _baseURI = baseURI;
        _maxCreatorTokens = maxCreatorTokens;
        _transactionFee = transactionFee;
        }

        function setRoyaltiesContract(address royaltiesContractAddress) external onlyOwner {
            require(royaltiesContractAddress != address(0), "CreatorToken: Royalties contract address cannot be zero address.");
            _royalties = Royalties(royaltiesContractAddress);
        }

        // TOKEN LIMITATIONS
        function setMaxCreatorTokens(uint256 maxTokens) public onlyOwner {_maxCreatorTokens = maxTokens;}
        function getMaxCreatorTokens() public view returns (uint256) {return _maxCreatorTokens;}
        function setBaseURI(string memory newBaseURI) public onlyOwner {_baseURI = newBaseURI; emit BaseURIUpdated(newBaseURI);}
        function baseURI() public view returns (string memory) {return _baseURI;}

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
        function transferToken(uint256 id, uint256 value, address from, address to) external payRoyaltiesOnTransfer(id, value, from, to) {
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

        // Anniversary Expansion function
        function expandToken(uint256 tokenId, uint256 amount) external payable onlyCreator {
            require(_totalSupply[tokenId] > 0, "CreatorToken: Token does not exist");
            require(_totalSupply[tokenId].add(amount) <= _maxCreatorTokens, "CreatorToken: Maximum cap exceeded");

            _mint(msg.sender, tokenId, amount, "");
            _totalSupply[tokenId] = _totalSupply[tokenId].add(amount);

            emit TokenMinted(tokenId, msg.sender, amount);
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
            require(tokenId != 0, "CreatorToken: Token ID cannot be 0");
            require(to != _creator[tokenId], "CreatorToken: Token creator cannot mint their own tokens");
            uint256 maxAllowedMint = getMaxAllowedMint(msg.sender, tokenId);
            require(amount <= maxAllowedMint, "CreatorToken: Exceeds maximum allowed mint amount");
            require(!_exists(tokenId), "CreatorToken: token already exists");
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

        // Destroy contract
        function destroy() public onlyOwner {
            selfdestruct(payable(owner()));
        }
}