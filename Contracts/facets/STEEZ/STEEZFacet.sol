// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {ISteezFacet} from "../interfaces/ISteezFacet.sol";

// CreatorToken.sol is a facet contract that implements the creator token logic and data for the SteeloToken contract
contract STEEZFacet is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable {
    using LibDiamond for LibDiamond.DiamondStorage;
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

    // EVENTS
    event TokenMinted(uint256 indexed tokenId, address indexed creator, uint256 amount);
    event PreOrderMinted(uint256 indexed tokenId, address indexed investor, uint256 amount);
    event TokenLaunched(uint256 indexed tokenId, uint256 price, uint256 totalSupply);
    event RoyaltyUpdated(uint256 indexed tokenId, address indexed user, uint256 updatedRoyaltyAmount);
    event Anniversary(uint256 indexed tokenId);
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

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.baseURI = baseURI;
        ds.maxCreatorTokens = maxCreatorTokens;
        ds.transactionFee = transactionFee;
        }

        // TOKEN LIMITATIONS
        function setMaxCreatorTokens(uint256 maxTokens) public onlyOwner {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.maxCreatorTokens = maxTokens;
        }
        
        function getMaxCreatorTokens() public view returns (uint256) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            return ds.maxCreatorTokens;
        }
        
        function setBaseURI(string memory newBaseURI) public onlyOwner {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.baseURI = newBaseURI;
            emit BaseURIUpdated(newBaseURI); // Ensure this event is declared in your contract
        }
        
        function baseURI() public view returns (string memory) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            return ds.baseURI;
        }

        // Transfer ownership to new owner
        function transferOwnership(address newInvestor, uint256 tokenId) public {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(newInvestor != address(0), "CreatorToken: Transfer to zero address");
            require(newInvestor != ds.creators[tokenId], "CreatorToken: Transfer to current owner");

            address currentInvestor = ds.Investors(tokenId);
            require(currentInvestor == msg.sender || ds.operatorApprovals[currentInvestor][msg.sender], "CreatorToken: Transfer caller is not owner nor approved");

            _transfer(currentInvestor, newInvestor, tokenId);

            // `_transfer` logic should be implemented to reflect diamond storage interaction
            ds.Investors[tokenId] = newInvestor;

                // Update balances accordingly in Diamond Storage
                if (_balances[tokenId][currentInvestor] == 0) {
                    _removeInvestor(tokenId, currentInvestor);
                }

                if (_balances[tokenId][newInvestor] > 0) {
                    _addInvestor(tokenId, newInvestor);
                }

            // Emit an event for the transfer
            emit OwnershipTransferred(currentInvestor, newInvestor, tokenId); // Ensure this event is declared in your contract
        }

        // Transfer token balance to specified address
        function transferToken(uint256 id, uint256 value, address from, address to) external payRoyaltiesOnTransfer(id, value, from, to) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(to != address(0), "CreatorToken: Transfer to zero address");
            require(from == msg.sender || ds.operatorApprovals[from][msg.sender], "CreatorToken: Transfer caller is not owner nor approved");
            require(to != ds.creators[tokenId], "CreatorToken: Creator cannot buy their own token");
            
            address currentInvestor = ownerOf(tokenId);
            address creator = _Creator[tokenId];
            bool isCreator = creator == currentInvestor && !(_balances[tokenId][currentInvestor] > 0);

            // The `_transfer` logic should be implemented to reflect diamond storage interaction
            ds._transfer(from, to, tokenId, value);
        
            if (_isInvestor(currentInvestor)) {
                // Transfer to an owner, don't add the Owner role to the recipient
                _transfer(currentInvestor, to, tokenId);
            } else {
                // Transfer to a user, add the Owner role to the recipient
                _transfer(currentInvestor, to, tokenId);
                _addRole(to, ROLE_OWNER);
            }

            if (_balances[tokenId][currentInvestor] == 0) {
                _removeInvestor(tokenId, currentInvestor);
            }

            if (_balances[tokenId][to] > 0) {
                _addInvestor(tokenId, to);
            }
            // Emit a Transfer event
            emit Transfer(from, to, tokenId, value); // Ensure this event is declared in your contract
        }

        // Create custom creator token
        function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) public onlyOwner dailySnapshot {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(!ds.tokenExists[tokenId], "CreatorToken: token already exists");
            require(to != address(0), "CreatorToken: Cannot mint to zero address");
            require(ds.totalSupply[tokenId] < ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap reached");
            require(amount > 0, "CreatorToken: Cannot mint zero amount");
            require(tokenId != 0, "CreatorToken: Token ID cannot be 0");
            require(to != ds.creators[tokenId], "CreatorToken: Token creator cannot mint their own tokens");

            // The `_mint` logic should be implemented to reflect diamond storage interaction
            ds._mint(to, tokenId, amount, data);

            uint256 maxAllowedMint = getMaxAllowedMint(msg.sender, tokenId);
            require(amount <= maxAllowedMint, "CreatorToken: Exceeds maximum allowed mint amount");

            // Set token creator and royalty
            if (_creator[tokenId] == address(0)) {
                address creator = msg.sender;
                _creator[tokenId] = creator;
                _royalty[tokenId].creatorRoyalty = TOKEN_CREATOR_ROYALTY;
                _royalty[tokenId].steeloRoyalty = STEELO_ROYALTY;
                _royalty[tokenId].communityRoyalty = COMMUNITY_ROYALTY;
            }

            // Update the transaction count and minting state
            ds.transactionCount[tokenId] += amount;
            ds.tokenExists[tokenId] = true;

            // Update the minting state for annual token increase
            if (ds.mintedInLastYear[tokenId] + amount <= ds.INITIAL_CAP * ds.TRANSACTION_MULTIPLIER) {
                ds.mintedInLastYear[tokenId] += amount;
                ds.lastMintTime[tokenId] = block.timestamp;
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
                    if (holder != creator) {
                        uint256 communityRoyalty = communityFee.mul(share).div(100);
                        _balances[tokenId][holder] = _balances[tokenId][holder].add(communityRoyalty);
                    }
                }
            }

            emit TokenMinted(tokenId, to, ds.totalSupply[tokenId]);
            _takeSnapshot();
            emit Mint(to, tokenId, amount, data); // Ensure this event is declared in your contract
        }

        // Pre-order function
        function preOrder(uint256 tokenId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(ds.creators[msg.sender], "CreatorToken: Only creators can pre-order tokens.");
            require(ds.totalSupply[tokenId] == 0, "CreatorToken: Pre-order has already been completed.");
            require(amount >= ds.PRE_ORDER_MINIMUM_SOLD, "CreatorToken: Minimum pre-order amount not reached.");

            _mint(msg.sender, tokenId, amount, "");
            ds.totalSupply[tokenId] += amount;

            emit PreOrderMinted(tokenId, msg.sender, amount);        
        }

        // Launch token function
        function launchToken(uint256 tokenId, uint256 amount) public payable {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(ds.creators[msg.sender], "CreatorToken: Only creators can launch tokens.");
            require(ds.totalSupply[tokenId] > 0, "CreatorToken: Pre-order must be completed first.");
            require(ds.totalSupply[tokenId] + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded.");
            require(amount > 0, "CreatorToken: Launch amount must be greater than zero");

            _mint(msg.sender, tokenId, amount, "");
            ds.totalSupply[tokenId] += amount;
            emit TokenLaunched(tokenId, msg.sender, ds.totalSupply[tokenId]);
        }

        // Anniversary Expansion function
        function expandToken(uint256 tokenId, uint256 amount) external payable onlyCreator {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(ds.totalSupply[tokenId] > 0, "CreatorToken: Token does not exist");
            require(ds.totalSupply[tokenId] + amount <= ds.MAX_CREATOR_TOKENS, "CreatorToken: Maximum cap exceeded");

            _mint(msg.sender, tokenId, amount, "");
            ds.totalSupply[tokenId] += amount;
            emit TokenMinted(tokenId, msg.sender, amount);
        }

        function expansionEligible(uint256 tokenId) public view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            return ds.transactionCount[tokenId] >= ds.totalSupply[tokenId] * 2;
        }

        // Function to check annual token increase eligibility and initiate the process
        function checkAndInitiateAnniversary(uint256 tokenId) public {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(ds.creators[tokenId] == msg.sender, "CreatorToken: Only the token creator can initiate an annual token increase.");
            require(block.timestamp >= ds.lastTokenIncrease[tokenId] + ds.ANNIVERSARY_DELAY, "CreatorToken: Annual token increase not yet available.");
            
            uint256 currentSupply = ds.totalSupply[tokenId];
            uint256 newSupply = currentSupply + (currentSupply * ds.ANNUAL_TOKEN_INCREASE_PERCENTAGE / 100);
            ds.totalSupply[tokenId] = newSupply;

            ds.lastTokenIncrease[tokenId] = block.timestamp;

            emit TokenSupplyIncreased(tokenId, newSupply);

            _initiateAnniversary(tokenId);
        }

        // Snapshot function
        function _takeSnapshot() internal {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.snapshotCounter++;

            for (uint256 tokenId = 1; tokenId <= ds.currentTokenID; tokenId++) {
                ds.snapshotBalances[ds.snapshotCounter][tokenId] = ds.totalSupply[tokenId];
            }
        }

        // Minting function
        function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) public onlyOwner dailySnapshot {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
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
            ds.transactionCount[tokenId] += amount;

            // Update the minting state for annual token increase
            if (_mintedInLastYear[tokenId].add(amount) <= INITIAL_CAP.mul(TRANSACTION_MULTIPLIER)) {
                _mintedInLastYear[tokenId] = _mintedInLastYear[tokenId].add(amount);
                _lastMintTime[tokenId] = block.timestamp;
            }

            emit TokenMinted(tokenId, to, _totalSupply[tokenId]);
            
            // Take a snapshot after minting tokens
            _takeSnapshot();
        }
}