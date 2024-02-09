// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "node_modules/@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./STEEZFacet.sol";

interface ISTEEZFacet {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    function creatorOf(uint256 tokenId) external view returns (address);   
    function ownerOf(uint256 tokenId, uint256 index) external view returns (address);
    function isOwnerOf(address account, uint256 tokenId) external view returns (bool);
    function totalSupply(uint256 tokenId) external view returns (uint256);
    function balanceOf(address account, uint256 tokenId) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
    function uri(uint256 tokenId) external view returns (string memory);
    function mint(address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
    function burn(address account, uint256 tokenId, uint256 amount) external;
}

struct Snapshot {
    uint256 blockNumber;
    uint256 value;
}

// Royalties.sol is a facet contract that implements the royalty logic and data for the SteeloToken contract
contract Royalties is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;

    // EVENTS
    event RoyaltyPaid(uint256 indexed tokenId, address indexed recipient, uint256 amount);
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    // MODIFIERS
    modifier payRoyaltiesOnTransfer(uint256 id, uint256 value, address from, address to) {
        _;
        payRoyalties(id, value, from, to);
    }

    modifier onlyAdmin() {
        require(ISTEEZFacet(_creatorTokenAddress).isAdmin(msg.sender), "Royalties: Caller is not an admin");
        _;
    }

    // Function to initialize the contract with the owner address
    function initialize(address owner) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        transferOwnership(owner);
    }

    // Function to listen to ownership events from CreatorToken.sol
    function setCreatorTokenAddress(address creatorTokenAddress) external onlyOwner {
        _creatorTokenAddress = creatorTokenAddress;
        ISTEEZFacet(_creatorTokenAddress).TransferSingle().add(this.onTransferSingle.selector);
    }

    function setRoyaltiesContract(address royaltiesContractAddress) external onlyOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(royaltiesContractAddress != address(0), "CreatorToken: Royalties contract address cannot be zero address.");
        ds.royaltiesContract = royaltiesContractAddress;
    }

    // Function to listen to transaction events from CreatorToken.sol
    function onTransferSingle(address operator, address from, address to, uint256 id, uint256 value) external {
        require(msg.sender == _creatorTokenAddress, "Royalties: Caller is not the CreatorToken contract");
        payRoyalties(id, value, from, to);
    }

    // Function to create a snapshot for a token
    function createSnapshot(uint256 tokenId) external onlyAdmin {
        uint256 totalUndistributed = _undistributedRoyalties[tokenId][address(this)];
        uint256 blockNumber = block.number;
        _totalUndistributedSnapshots[tokenId].push(Snapshot(blockNumber, totalUndistributed));

        // Iterate through the holders and create a snapshot for each one
        CreatorToken parent = CreatorToken(owner());
        uint256 totalSupply = parent.totalSupply(tokenId);

        for (uint256 i = 0; i < totalSupply; i++) {
            address holder = parent.ownerOf(tokenId, i);
            uint256 holderBalance = parent.balanceOf(holder, tokenId);
            _holderSnapshots[tokenId][holder].push(Snapshot(blockNumber, holderBalance));
        }
    }

    // Function to distribute community royalties for a token
    function distributeCommunityRoyalties(uint256 tokenId) external {
        require(tokenId > 0, "Royalties: Invalid token ID");

        CreatorToken parent = CreatorToken(owner());
        uint256 totalSupply = parent.totalSupply(tokenId);
        require(totalSupply > 0, "Royalties: Token has no supply");

        uint256 communityRoyalty = _communityRoyaltyRates[tokenId];
        require(communityRoyalty > 0, "Royalties: Token has no community royalty");

        // Calculate the share of each token holder based on their balance and the undistributed royalties
        uint256 sharePerToken = _undistributedRoyalties[tokenId][address(this)].div(totalSupply);
        for (uint256 i = 0; i < totalSupply; i++) {
            address holder = parent.ownerOf(tokenId, i);
            uint256 balance = parent.balanceOf(holder, tokenId);
            uint256 share = sharePerToken.mul(balance);
            _undistributedRoyalties[tokenId][holder] = _undistributedRoyalties[tokenId][holder].add(share);
            _undistributedRoyalties[tokenId][address(this)] = _undistributedRoyalties[tokenId][address(this)].sub(share);
        }
    }

    // Function to claim community royalties for a token
    function claimCommunityRoyalties(uint256 tokenId) external nonReentrant {
        require(tokenId > 0, "Royalties: Invalid token ID");

        // Find the correct snapshot for the holder and the total undistributed royalties
        uint256 holderSnapshotIndex = _findSnapshotIndex(tokenId, msg.sender);
        uint256 totalSnapshotIndex = _findSnapshotIndex(tokenId, address(this));

        uint256 holderBalance = _holderSnapshots[tokenId][msg.sender][holderSnapshotIndex].value;
        uint256 totalUndistributed = _totalUndistributedSnapshots[tokenId][totalSnapshotIndex].value;
        uint256 holderShare = totalUndistributed.mul(holderBalance).div(totalSupply);

        require(holderShare > 0, "Royalties: No royalties to claim");

        // Transfer the royalties to the token holder
        payable(msg.sender).transfer(holderShare);

        // Update the undistributed royalties
        _undistributedRoyalties[tokenId][msg.sender] = _undistributedRoyalties[tokenId][msg.sender].sub(holderShare);
        _undistributedRoyalties[tokenId][address(this)] = _undistributedRoyalties[tokenId][address(this)].sub(holderShare);
    }

    // Function to pay royalties for a token transfer (triggered by the TransferSingle event on CreatorToken.sol)
    function payRoyalties(uint256 tokenId, uint256 salePrice, address seller, address buyer) external payable {
        require(tokenId > 0, "Royalties: Invalid token ID");
        require(salePrice > 0, "Royalties: Invalid sale price");
        require(msg.value >= salePrice, "Royalties: Insufficient payment");
        require(msg.sender == owner(), "Royalties: Caller is not the owner");
        _communityRoyaltyRates[tokenId] = communityRate;

        uint256 creatorRate;
        uint256 steeloRate;
        uint256 communityRate;

        if (seller == owner()) {
            if (buyer == owner()) {
                creatorRate = PRE_ORDER_CREATOR_RATE; // pre-order sale
                steeloRate = PRE_ORDER_STEELO_RATE;
                communityRate = 0;
            } else {
                creatorRate = LAUNCH_CREATOR_RATE; // launch or expansion sale
                steeloRate = LAUNCH_STEELO_RATE;
                communityRate = LAUNCH_COMMUNITY_RATE;
            }
        } else {
            creatorRate = SECOND_HAND_CREATOR_RATE; // second-hand sale
            steeloRate = SECOND_HAND_STEELO_RATE;
            communityRate = SECOND_HAND_COMMUNITY_RATE;
        }

        // Pay the creator royalty
        uint256 creatorAmount = salePrice.mul(creatorRate).div(1000); // divide by 1000 to get correct percentage
        payable(seller).transfer(creatorAmount);

        // Pay the Steelo royalty
        uint256 steeloAmount = salePrice.mul(steeloRate).div(1000); // divide by 1000 to get correct percentage
        payable(owner()).transfer(steeloAmount);

        // Add the community royalty to the undistributed pool
        uint256 communityAmount = salePrice.mul(communityRate).div(1000); // divide by 1000 to get correct percentage
        _undistributedRoyalties[tokenId][address(this)] = _undistributedRoyalties[tokenId][address(this)].add(communityAmount);

        // Pay the seller royalty (only for second-hand sales)
        if (seller != owner()) {
            uint256 sellerAmount = salePrice.mul(SECOND_HAND_SELLER_RATE).div(1000); // divide by 1000 to get correct percentage
            payable(seller).transfer(sellerAmount);
        }
    }

    // Helper function to find the correct snapshot index
    function _findSnapshotIndex(uint256 tokenId, address account) private view returns (uint256) {
        Snapshot[] storage snapshots = _holderSnapshots[tokenId][account];
        uint256 left = 0;
        uint256 right = snapshots.length;

        while (left < right) {
            uint256 mid = left.add(right).div(2);
            if (snapshots[mid].blockNumber <= block.number) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return left.sub(1);
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

        // Update royalty function
        function updateRoyalty(uint256 tokenId, address user, uint256 amount) external onlyCreator {
            require(_creator[tokenId] == msg.sender, "CreatorToken: Caller is not the creator of the token");
            require(_tokenExists[tokenId], "CreatorToken: Token does not exist");

            _undistributedRoyalties[tokenId][user] = _undistributedRoyalties[tokenId][user].add(amount);

            emit RoyaltyUpdated(tokenId, user, amount);
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
}