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
import "node_modules/@gnosis.pm/safe-contracts/contracts/interfaces/ISafe.sol";
import "node_modules/@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "node_modules/@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";

contract SteeloToken is ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint256;

    // Constants
    uint256 private constant MAX_CREATOR_TOKENS = 500;
    uint256 private constant INITIAL_CAP = 500;
    uint256 private constant TRANSACTION_MULTIPLIER = 2;

    // Royalties
    uint256 private constant TOKEN_CREATOR_ROYALTY = 50; // 5%
    uint256 private constant STEELO_ROYALTY = 25; // 2.5%
    uint256 private constant HOLDER_ROYALTY = 25; // 2.5%

    // State variables
    Counters.Counter private _currentTokenID;
    string private _baseURI;
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

    // Events
    event TokenMinted(uint256 indexed tokenId, address indexed creator, uint256 totalSupply);
    event AnnualTokenIncrease(uint256 indexed tokenId);
    event RoyaltyUpdated(uint256 indexed tokenId, address indexed user, uint256 updatedRoyaltyAmount);

    // Modifiers
    modifier dailySnapshot() {
    if (block.timestamp >= _lastSnapshotTimestamp.add(1 days)) {
        _takeSnapshot();
        _lastSnapshotTimestamp = block.timestamp;
    }
    _;
}

    // Functions

        // Initialize With Safe-Global's MultiSig Wallet
        function initializeWithSafe(string memory baseURI, address safeAddress) public initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init_unchained(safeAddress);
        __Pausable_init_unchained();

        _baseURI = baseURI;

            // Gnosis Safe multisig setup code (to be setup) --> GPT
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