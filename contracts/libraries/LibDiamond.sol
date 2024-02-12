// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

error InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
        uint256 public constant TGE_AMOUNT = 825_000_000 * 10**18;
        uint256 public constant pMin = 0.5 ether;
        uint256 public constant pMax = 5 ether;
        uint256 public constant BURN_THRESHOLD = 1e9;
        uint256 private constant INITIAL_CAP = 500;
        uint256 private constant TRANSACTION_MULTIPLIER = 2;
        uint256 private constant PRE_ORDER_MINIMUM_SOLD = 125; // 50% of 250
        uint256 public constant INITIAL_PRICE = 30 ether; // Assuming pricing in WEI for simplicity
        uint256 public constant PRICE_INCREMENT = 10 ether; // Increment value
        uint256 public constant TOKEN_BATCH_SIZE = 250;
        uint256 public constant AUCTION_DURATION = 24 hours;
        address private constant GNOSIS_SAFE_MASTER_COPY = 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F;
        address private constant GNOSIS_SAFE_PROXY_FACTORY = 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F48;
        address public constant STEELO_WALLET = 0x1234567890123456789012345678901234567890; // Placeholder address
        uint256 public constant rho = 1 ether;
        uint256 public constant alpha = 10;
        uint256 public constant beta = 10;

        uint256 constant PRE_ORDER_CREATOR_ROYALTY = 90; // 90% of pre-order sale value to creator
        uint256 constant PRE_ORDER_STEELO_ROYALTY = 10; // 10% of pre-order sale value to Steelo
        uint256 constant LAUNCH_CREATOR_ROYALTY = 90; // 90% of launch + expansion sale value to creator
        uint256 constant LAUNCH_STEELO_ROYALTY = 75; // 7.5% of launch + expansion sale value to Steelo
        uint256 constant LAUNCH_COMMUNITY_ROYALTY = 25; // 2.5% of launch + expansion sale value to token holders
        uint256 constant SECOND_HAND_SELLER_ROYALTY = 90; // 90% of second-hand sale value to seller
        uint256 constant SECOND_HAND_CREATOR_ROYALTY = 50; // 5% of second-hand sale value to creator
        uint256 constant SECOND_HAND_STEELO_ROYALTY = 25; // 2.5% of second-hand sale value to Steelo
        uint256 constant SECOND_HAND_COMMUNITY_ROYALTY = 25; // 2.5% of second-hand sale value to token holders

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        assembly {
            ds.slot := STORAGE_SLOT
        }
    }

        mapping(address => uint256) public stakes;
        mapping(address => bool) public isStakeholder;
        mapping (address => bool) private admins;
        mapping (address => bool) private creators;
        mapping (address => bool) private owners; // to rename to investors
        mapping (address => bool) private users;
        mapping(address => bool) private _hasCreatedToken;
        mapping(uint256 => bool) private _tokenExists; 
        mapping(uint256 => uint256) private _totalSupply;
        mapping(address => uint256) private _shareholdings;
        mapping(uint256 => uint256) private _transactionCount;
        mapping(uint256 => uint256) private _mintedInLastYear;
        mapping(uint256 => uint256) private _lastMintTime;
        mapping(uint256 => uint256[]) public creatorSplits;
        mapping(uint256 => uint256[]) public communitySplits;
        mapping(uint256 => address[]) public tokenHolders;
        mapping(uint256 => mapping(address => uint256)) public balances;
        mapping(uint256 => mapping(address => uint256)) public distributionPolicies;
        mapping(uint256 => mapping(uint256 => uint256)) private _snapshotBalances;
        mapping(uint256 => uint256) private _lastSnapshot;

        address public treasury; uint256 public trasuryTGE = 35; uint256 public treasuryMint = 35;
        address public liquidityProviders = 0x22a909748884b504bb3BDC94FAE155aaa917416D; uint256 public liquidityProvidersMint = 55;
        address public ecosystemProviders = 0x5dBfD5E645FF0714dc71c3cbcADAAdf163d5971D; uint256 public ecosystemProvidersMint = 10;
        address public foundersAddress = 0x0620F316431EE739a1c1EeD54980aF5EAF5B8E49; uint256 public foundersTGE = 20;
        address public earlyInvestorsAddress = 0x6Eaa165659fbd96C10DBad3C3A89396225aEEde8; uint256 public earlyInvestorsTGE = 10;
        address public communityAddress = 0xB6912a7F733287BE95Aca28E1C563FA3Ed0BeFde; uint256 public communityTGE = 35;
        address public steeloAddresss = 0x45F9B54cB97970c0E798dB0FDF2b8076Cdf57d25;  uint256 public FEE_RATE = 25;

        modifier canCreateToken(address creator) {require(!_hasCreatedToken[creator], "CreatorToken: Creator has already created a token."); _;}
        modifier onlyAdmin() {require(admins[msg.sender], "Only Admin can call this function"); _;}
        modifier onlyCreator() {require(creatorToIsAdmin[msg.sender] == false && msg.sender != creator, "CreatorToken: Only Creators can call this function"); _;}
        modifier onlyOwner() {require(creatorToIsAdmin[msg.sender] == false && msg.sender != creator && msg.sender != owner(), "CreatorToken: Only Owners can call this function"); _;}
        modifier onlyUser() {require(users[msg.sender], "Only User can call this function"); _;}
        modifier onlyCreatorOrOwner() {require(owners[msg.sender] || creators[msg.sender], "CreatorToken: Only Creators or Owners can call this function"); _;}
        modifier dailySnapshot() {if (block.timestamp >= _lastSnapshotTimestamp.add(1 days)) {_takeSnapshot(); _lastSnapshotTimestamp = block.timestamp;} _;}
        
    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {

        // Diamond Standard parameters
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;

        // Add more fields as needed...
        ISteezFeesFacet steezFeesFacet;
        ISteezFacet steezFacet;

        // Chainlink parameters
        address oracle;
        bytes32 jobId;
        uint256 fee;
        uint256 volume;

        // ProfileFacet.So
        mapping(address => ProfileInfo) profiles;
        mapping(string => bool) usernameExists;
        string username;
        string bio;
        string avatarURI; // URI to user's avatar image
        address walletAddress; // The user's wallet address
        // Additional fields can be added as needed

        // STEELOFacet.sol Constants
        int256 steezTransactionCount;
        uint256 steeloCurrentPrice;
        uint256 steezCurrentPrice;
        uint256 totalMinted; 
        uint256 totalBurned;
        uint256 lastMintEvent; 
        uint256 lastBurnUpdate;
        uint256 mintAmount;
        uint256 burnAmount;
        uint256 burnRate;
        uint256 mintRate;
        bool isDeflationary;
        bool tgeExecuted;

        // STEEZFacet.sol Constants
        Royalties _royalties;

        // STEEZFacet.sol Variables
        string _baseURI;
        uint256 _maxCreatorTokens;
        uint256 _transactionFee;
        uint256 _totalShareholdings;

        // STEEZFacet.sol Snapshots
        CountersUpgradeable.Counter _currentTokenID;
        CountersUpgradeable.Counter _snapshotCounter;
        uint256 _lastSnapshotTimestamp;
        uint256 _snapshotCounter;

        // STEEZFacet.solCONTRACT ADDRESSES
        address _safeAddress;

        // STEEZFeesFacet.sol Addresses
        address _creatorTokenAddress;

        // SteezFeesFacet.sol Mapping
        mapping(uint256 => mapping(address => uint256)) _undistributedRoyalties;
        mapping(uint256 => uint256) _communityRoyaltyRates;
        mapping(uint256 => mapping(address => Snapshot[])) _holderSnapshots;
        mapping(uint256 => Snapshot[]) _totalUndistributedSnapshots;

    }
    
    // Example method in LibDiamond for batch updating royalties
    function updateRoyaltyRates(uint256[] calldata tokenIds, RoyaltyInfo[] calldata newRoyalties) external {
        require(tokenIds.length == newRoyalties.length, "Mismatched arrays");
        LibDiamond.enforceIsContractOwner();
        for(uint i = 0; i < tokenIds.length; i++) {
            diamondStorage().royaltyInfo[tokenIds[i]] = newRoyalties[i];
        }
    }

    // Function to check if a username already exists
    function usernameTaken(string memory username) internal view returns (bool) {
        return diamondStorage().usernameExists[username];
    }

    // Function to create or update a profile
    function setProfile(address user, string memory username, string memory bio, string memory avatarURI) internal {
        require(!usernameTaken(username), "Username already taken");
        diamondStorage storage ds = diamondStorage();
        ds.profiles[user] = ProfileInfo(username, bio, avatarURI, user);
        ds.usernameExists[username] = true;
    }

    // Function to retrieve a user's profile
    function getProfile(address user) internal view returns (ProfileInfo memory) {
        return diamondStorage().profiles[user];
    }

    // Increment the snapshot counter to create a new snapshot
    function _incrementSnapshot() internal returns (uint256) {
        return ++snapshotCounter;
    }

    // Record the balance for an address at the current snapshot
    function _snapshotBalance(address account, uint256 balance) internal {
        uint256 currentId = _incrementSnapshot();
        snapshotBalances[currentId][account] = balance;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();        
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);            
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress != _facetAddress, "LibDiamondCut: Can't replace function with same function");
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        require(_facetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
        }
    }

    function addFacet(DiamondStorage storage ds, address _facetAddress) internal {
        enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds.facetAddresses.length;
        ds.facetAddresses.push(_facetAddress);
    }    


    function addFunction(DiamondStorage storage ds, bytes4 _selector, uint96 _selectorPosition, address _facetAddress) internal {
        ds.selectorToFacetAndPosition[_selector].functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(_selector);
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(DiamondStorage storage ds, address _facetAddress, bytes4 _selector) internal {        
        require(_facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
        // an immutable function is a function defined directly in a diamond
        require(_facetAddress != address(this), "LibDiamondCut: Can't remove immutable function");
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint96(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = facetAddressPosition;
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            return;
        }
        enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");        
        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                // bubble up error
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(error)
                    revert(add(32, error), returndata_size)
                }
            } else {
                revert InitializationFunctionReverted(_init, _calldata);
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}