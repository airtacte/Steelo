// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "../../libraries/LibDiamond.sol";

contract SteezManagementFacet is AccessControlUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event BaseURIUpdated(string baseURI);
    event MaxCreatorTokensUpdated(uint256 maxTokens);
    event CreatorAddressUpdated(uint256 indexed tokenId, address indexed newCreatorAddress);
    event CreatorSplitUpdated(uint256 indexed tokenId, uint256[] newSplits);
    event TokenHoldersUpdated(uint256 indexed tokenId, address[] tokenHolders, uint256[] shares);
    event DistributionPolicyUpdated(uint256 indexed tokenId);
    event Paused();
    event Unpaused();

    function initialize(address owner) public initializer {
        __AccessControl_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
    }

        // Update the maximum number of creator tokens
        function setMaxCreatorTokens(uint256 maxTokens) public onlyRole(MANAGER_ROLE) {
            require(maxTokens >= ds.totalTokensCreated, "Cannot set max below current total");
            require(maxTokens > 0, "Max tokens must be positive");
            require(!_isCreator(newCreatorAddress), "Address is already a creator");
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.maxCreatorTokens = maxTokens;
            emit MaxCreatorTokensUpdated(maxTokens);
        }
        
        // Retrieve the maximum number of creator tokens
        function getMaxCreatorTokens() public view returns (uint256) {
            return LibDiamond.diamondStorage().maxCreatorTokens;
        }

        // Update the base URI for token metadata
        function setBaseURI(string memory newBaseURI) public onlyRole(MANAGER_ROLE) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.baseURI = newBaseURI;
            emit BaseURIUpdated(newBaseURI);
        }

        // Retrieve the current base URI
        function baseURI() public view returns (string memory) {
            return LibDiamond.diamondStorage().baseURI;
        }

        // Update the creator's address for a specific token
        function updateCreatorAddress(uint256 tokenId, address newCreatorAddress) external onlyRole(MANAGER_ROLE) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            require(newCreatorAddress != address(0), "New creator address cannot be zero address");
            require(tokenId > 0, "Token ID must be positive");
            ds.creatorAddresses[tokenId] = newCreatorAddress;
            emit CreatorAddressUpdated(tokenId, newCreatorAddress);
        }

        // Retrieve the current creator address for a specific token
        function getCreatorAddress(uint256 tokenId) public view returns (address) {
            return _creator[tokenId];
        }

        // Update the revenue or royalty split for a specific token
        function setCreatorSplit(uint256 tokenId, uint256[] memory splits) external onlyRole(MANAGER_ROLE) {
            uint256 total = 0;
            for (uint256 i = 0; i < splits.length; i++) {
                total += splits[i];
                require(splits[i] > 0, "Split must be positive");
            }
            require(total == 100, "Total split must be 100");

            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.creatorSplits[tokenId] = splits;
            emit CreatorSplitUpdated(tokenId, splits);
            emit DistributionPolicyUpdated(tokenId);
        }

        // Set token holders and their respective shares for a specific token
        function setTokenHolders(uint256 tokenId, address[] memory _tokenHolders, uint256[] memory shares) external onlyRole(MANAGER_ROLE) {
            require(_tokenHolders.length == shares.length, "Arrays must have the same length");
            uint256 total = 0;
            for (uint256 i = 0; i < shares.length; i++) {
                total += shares[i];
            require(_tokenHolders[i] != address(0), "Holder address cannot be zero");
            require(shares[i] > 0, "Share must be positive");
        }
            require(total == 100, "Total shares must be 100");

            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            ds.tokenHolders[tokenId] = _tokenHolders;
            ds.communitySplits[tokenId] = shares;
            emit TokenHoldersUpdated(tokenId, _tokenHolders, shares);
        }

        // Check if the given token exists and returns an array of unique addresses that hold the token
        function getHolders(uint256 tokenId) public view returns (address[] memory) {
            require(_exists(tokenId), "CreatorToken: Token does not exist");
            return LibDiamond.diamondStorage().tokenHolders[tokenId];
        }

        // Pause function
        function pause() public onlyRole(PAUSER_ROLE) {
            _pause();
            emit Paused();
        }

        // Unpause function
        function unpause() public onlyRole(PAUSER_ROLE) {
            _unpause();
            emit Unpaused();
        }

        // Fallback function
        receive() external payable {}

        // Function to take a snapshot of the current token balances
        function _takeSnapshot() internal {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            // Assuming snapshotCounter and snapshotBalances are properly defined in LibDiamond
            ds.snapshotCounter++;
            for (uint256 tokenId = 1; tokenId <= ds.currentTokenID; tokenId++) {
                ds.snapshotBalances[ds.snapshotCounter][tokenId] = ds.totalSupply[tokenId];
            }
            // Emitting an event could be considered here to log snapshot actions
        }

        // Helper function to check if an address is already a creator
        function _isCreator(address addr) private view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            for (uint256 i = 1; i <= ds.currentTokenID; i++) {
                if(ds.creatorAddresses[i] == addr) {
                    return true;
                }
            }
            return false;
        }

        // Ensure the token exists
        function _exists(uint256 tokenId) private view returns (bool) {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            return ds.tokenExists[tokenId];
        }
}