// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity 0.8.20;

import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

error InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    uint private _lastSnapshotTimestamp;
    uint private snapshotCounter;
    mapping(uint256 => mapping(address => uint256)) private _snapshotBalances;
    bool private _takeSnapshot;
    
    modifier dailySnapshot() {if (block.timestamp >= _lastSnapshotTimestamp.add(1 days)) {_takeSnapshot(); _lastSnapshotTimestamp = block.timestamp;} _;}

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        assembly {
            ds.slot := STORAGE_SLOT
        }
    }
    
    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition;
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition;
    }

    // STEELO MULTI-SIG WALLETS
    address private constant GNOSIS_SAFE_MASTER_COPY = 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F;
    address private constant GNOSIS_SAFE_PROXY_FACTORY = 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F48;
    address private constant STEELO_WALLET = 0x45F9B54cB97970c0E798dB0FDF2b8076Cdf57d25;

    // STEELO TOKENOMICS
    uint256 public constant TGE_AMOUNT = 825_000_000 * 10**18;
    uint256 public constant BURN_THRESHOLD = 1e9;
    uint256 public constant pMin = 0.5 ether;
    uint256 public constant pMax = 5 ether;
    uint256 private constant rho = 1 ether;
    uint256 private constant alpha = 10;
    uint256 private constant beta = 10;

    // STEEZ TOKENOMICS
    uint256 public constant INITIAL_CAP = 500;
    uint256 public constant TRANSACTION_MULTIPLIER = 2;
    uint256 public constant PRE_ORDER_MINIMUM_SOLD = 250; // 100% of 250
    uint256 public constant INITIAL_PRICE = 30 ether; // Assuming pricing in WEI for simplicity
    uint256 public constant PRICE_INCREMENT = 10 ether; // Increment value
    uint256 public constant TOKEN_BATCH_SIZE = 250;
    uint256 public constant AUCTION_DURATION = 24 hours;
    uint256 public constant PRE_ORDER_CREATOR_ROYALTY = 90; // 90% of pre-order sale value to creator
    uint256 public constant PRE_ORDER_STEELO_ROYALTY = 10; // 10% of pre-order sale value to Steelo
    uint256 public constant LAUNCH_CREATOR_ROYALTY = 90; // 90% of launch + expansion sale value to creator
    uint256 public constant LAUNCH_STEELO_ROYALTY = 75; // 7.5% of launch + expansion sale value to Steelo
    uint256 public constant LAUNCH_COMMUNITY_ROYALTY = 25; // 2.5% of launch + expansion sale value to token holders
    uint256 public constant SECOND_HAND_SELLER_ROYALTY = 90; // 90% of second-hand sale value to seller
    uint256 public constant SECOND_HAND_CREATOR_ROYALTY = 50; // 5% of second-hand sale value to creator
    uint256 public constant SECOND_HAND_STEELO_ROYALTY = 25; // 2.5% of second-hand sale value to Steelo
    uint256 public constant SECOND_HAND_COMMUNITY_ROYALTY = 25; // 2.5% of second-hand sale value to token holders

    // STEEZ ROYALTY DISTRIBUTION
    address public treasury; uint256 public trasuryTGE = 35; uint256 public treasuryMint = 35;
    address public liquidityProviders = 0x22a909748884b504bb3BDC94FAE155aaa917416D; uint256 public liquidityProvidersMint = 55;
    address public ecosystemProviders = 0x5dBfD5E645FF0714dc71c3cbcADAAdf163d5971D; uint256 public ecosystemProvidersMint = 10;
    address public foundersAddress = 0x0620F316431EE739a1c1EeD54980aF5EAF5B8E49; uint256 public foundersTGE = 20;
    address public earlyInvestorsAddress = 0x6Eaa165659fbd96C10DBad3C3A89396225aEEde8; uint256 public earlyInvestorsTGE = 10;
    address public communityAddress = 0xB6912a7F733287BE95Aca28E1C563FA3Ed0BeFde; uint256 public communityTGE = 35;
    address public steeloAddresss = 0x45F9B54cB97970c0E798dB0FDF2b8076Cdf57d25;  uint256 public FEE_RATE = 25;

    struct Snapshot {
        uint256 id;
        uint256 timestamp;
        uint256 value;
        mapping(address => uint256) balances;
    }

    struct DiamondStorage {

        // Diamond Standard parameters
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        mapping(bytes4 => bool) supportedInterfaces;
        address[] facetAddresses;
        address contractOwner;

        // Chainlink parameters
        address oracle;
        bytes32 jobId;
        uint256 fee;
        uint256 volume;
    }

    // Increment the snapshot counter to create a new snapshot
    function _incrementSnapshot() internal returns (uint256) {
        return ++snapshotCounter;
    }

    // Record the balance for an address at the current snapshot
    function snapshotBalances(address account, uint256 balance) internal {
        uint256 currentId = _incrementSnapshot();
        _snapshotBalances[currentId][account] = balance;
    }

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