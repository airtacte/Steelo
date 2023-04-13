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
    mapping(uint256 => uint256) private _mintedInLastYear;
    mapping(uint256 => uint256) private _lastMintTime;
    mapping(uint256 => uint256) private _lastSnapshot;

    // Events
    event TokenMinted(uint256 indexed tokenId, address indexed creator, uint256 totalSupply);
    event AnnualTokenIncrease(uint256 indexed tokenId);

    function initializeWithSafe(string memory baseURI, address safeAddress) public initializer {
        __ERC1155_init("https://myapi.com/api/token/{id}.json");
        __Ownable_init_unchained(safeAddress);
        __Pausable_init_unchained();

        _baseURI = baseURI;

        // Gnosis Safe multisig setup code (to be setup) --> GPT
    }


    // Minting function
    function mint(address to, uint256 tokenId, uint256 amount, bytes memory data) public onlyOwner {
        require(_currentTokenID.current() < type(uint256).max, "SteeloToken: TokenID overflow");
        require(_totalSupply[tokenId] < MAX_CREATOR_TOKENS, "SteeloToken: Maximum cap reached");

    // Set token creator and royalty
    if (_creator[tokenId] == address(0)) {
        _creator[tokenId] = to;
        _royalty[tokenId] = TOKEN_CREATOR_ROYALTY.add(STEELO_ROYALTY).add(HOLDER_ROYALTY);
    }

    // Update the transaction count
    _transactionCount[tokenId] = _transactionCount[tokenId].add(amount);

    // Update the minting state for annual token increase
    if (_mintedInLastYear[tokenId].add(amount) <= INITIAL_CAP.mul(TRANSACTION_MULTIPLIER)) {
        _mintedInLastYear[tokenId] = _mintedInLastYear[tokenId].add(amount);
        _lastMintTime[tokenId] = block.timestamp;
    }

    // Mint the tokens
    _mint(to, tokenId, amount, data);
    _totalSupply[tokenId] = _totalSupply[tokenId].add(amount);

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

function expansionEligible(/* parameters */) public view returns (bool) {
    // Expansion eligibility check
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
) public {
    _transferWithRoyalty(from, to, tokenId, amount);
}

function _transferWithRoyalty(
    address from,
    address to,
    uint256 tokenId,
    uint256 amount
) internal {
    // TODO: Implement royalty calculation and distribution based on the snapshot mechanism

    // Call the ERC1155 transfer function
    _safeTransferFrom(from, to, tokenId, amount, "");
}
}