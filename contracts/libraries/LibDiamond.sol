// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import { ConstDiamond } from "./ConstDiamond.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

error InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DiamondStorage {
        // Standard Diamond Storage Mappings
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        mapping(bytes4 => bool) supportedInterfaces;
        address[] facetAddresses;
        address contractOwner;
        Constants constants; // reference to contracts\libraries\ConstDiamond.sol

        // Steelo & Steez struct references
        mapping(address => Steez) steez; // Added mapping from creator address to Steez
        mapping(uint256 => Creator) creators; // Added mapping from creatorId to Creator
        mapping(address => Investor) investors; // Added mapping from investor address to Investor
        mapping(uint256 => Royalty) royalties; // Added mapping from creatorId to QueuedRoyalty
        mapping(uint256 => Content) content; // Added mapping from contentId to Content Firebase Document
        mapping(uint256 => Contributor) contributors; // Added mapping from contributorId to Contributor
        QueuedRoyalty[] royaltyQueue;

        // FACETS
        address constDiamondAddress;

        address accessControlFacetAddress;
        address gasOptimisationFacetAddress;
        address multiSigFacetAddress;
        address notificationFacetAddress;
        address snapshotFacetAddress;
        address socialNetworkFacetAddress;

        address bazaarFacetAddress;
        address galleryFacetAddress;
        address mosaicFacetAddress;
        address profileFacetAddress; 
        address villageFacetAddress;

        address sipFacetAddress;
        address steeloFacetAddress;
        address steeloGovernanceFacetAddress;
        address steeloStakingFacetAddress;

        address steezFacetAddress;
        address steezFeesFacetAddress;
        address steezGovernanceFacetAddress;
        address steezManagementFacetAddress;

        // STEEZFacet.sol VARIABLES
        uint256 _lastCreatorId;
        uint256 _lastProfileId;
        uint256 _lastSteezId;
        string baseURI;

        // Chainlink parameters
        address oracle;
        bytes32 jobId;
        uint256 fee;
        uint256 volume;
    }

    struct Constants {
        // STEELO TOKENOMICS
        uint256 TGE_AMOUNT;
        uint256 pMin;
        uint256 pMax;
        uint256 rho;
        uint256 alpha;
        uint256 beta;
        uint256 MIN_MINT_RATE;
        uint256 MAX_MINT_RATE;
        uint256 MIN_BURN_RATE;
        uint256 MAX_BURN_RATE;

        // STEEZ TOKENOMICS
        uint256 AUCTION_DURATION;
        uint256 PRE_ORDER_SUPPLY;
        uint256 LAUNCH_SUPPLY;
        uint256 EXPANSION_SUPPLY;
        uint256 TRANSACTION_MULTIPLIER;
        uint256 INITIAL_PRICE;
        uint256 PRICE_INCREMENT;
        uint256 TOKEN_BATCH_SIZE;
        uint256 PRE_ORDER_CREATOR_ROYALTY;
        uint256 PRE_ORDER_STEELO_ROYALTY;
        uint256 LAUNCH_CREATOR_ROYALTY;
        uint256 LAUNCH_STEELO_ROYALTY;
        uint256 LAUNCH_COMMUNITY_ROYALTY;
        uint256 SECOND_HAND_SELLER_ROYALTY;
        uint256 SECOND_HAND_CREATOR_ROYALTY;
        uint256 SECOND_HAND_STEELO_ROYALTY;
        uint256 SECOND_HAND_COMMUNITY_ROYALTY;

        // STAKEHOLDER'S ROYALTY DISTRIBUTION
        address treasury;
        uint256 trasuryTGE;
        uint256 treasuryMint;
        address liquidityProviders;
        uint256 liquidityProvidersMint;
        address ecosystemProviders;
        uint256 ecosystemProvidersMint;
        address foundersAddress;
        uint256 foundersTGE;
        address earlyInvestorsAddress;
        uint256 earlyInvestorsTGE;
        address communityAddress;
        uint256 communityTGE;
        address steeloAddresss;
        uint256 FEE_RATE;
        address uniswapAddress;
        address gbptAddress;

        uint256 oneYear;
        uint256 oneWeek;
    }

    struct Investor {
        uint256 profileId; // ID of the investor's user profile
        address investorAddress; // address of the investor
        uint256 balance; // quantity of Steez owned by the investor
    }

    struct Royalty {
        uint256 totalRoyalties; // in Steelo, equiv. to 10% of the price of Steez transacted on Bazaar
        uint256 unclaimedRoyalties; // Total unclaimed royalties for this Steez
        uint256 creatorRoyalties; // in Steelo, equiv. to 5% of the price of Steez transacted on Bazaar
        uint256 investorRoyalties; // in Steelo, equiv. to 2.5% of the price of Steez transacted on Bazaar
        uint256 steeloRoyalties; // in Steelo, equiv. to 2.5% of the price of Steez transacted on Bazaar
        mapping(address => uint256) royaltyAmounts; // Mapping from investor address to the total amount of royalties received
        mapping(address => uint256[]) royaltyPayments; // Mapping from investor address to array of individual royalty payments received
    }
    
    struct Steez {
        uint256 creatorId; // one creatorId holds 500+ steezIds
        uint256 steezId; // mapping(creatorId => mapping(steezId => investors)
        uint256 totalSupply; // starting at 500 and increasing by 500 annually
        uint256 transactionCount; // drives anniversary requirements and $STEELO mint rate 
        uint256 lastMintTime; // to check when to next initiate Anniversary
        uint256 anniversaryDate; // to check when to next initiate Anniversary
        uint256 currentPrice; // determined by pre-order auction price, then via Supply x Demand AMM model
        uint256 auctionStartTime; // 250 out of the 500 initially minted tokens for pre-order
        uint256 auctionSlotsSecured; // increments price by £10 every 250 token auctions at new price 
        string baseURI; // base URI for token metadata
        bool creatorExists; // only one steez per creator
        bool auctionConcluded; // 24hr auction after 1 week of pre-order
        Investor[] investors; // investors array updated to show "current holders"
        Royalty royalties; // Integrated Royalty struct for managing royalties
    }

    struct Creator {
        uint256 creatorId;
        uint256 profileId;
        address profileAddress;
        mapping(uint256 => Content) content; // Assuming Document is a struct that represents a document stored in Firebase
        mapping(address => Investor) investors; // Assuming Investor is a struct that represents an investor
        mapping(uint256 => Contributor[]) credits; // Assuming Contributor is a struct that represents a contributor
    }

    struct Content {
        uint256 contentId;
        uint256 creatorId;
        string contentURI;
        string contentHash;
        string contentType;
        uint256 contentSize;
        uint256 contentPrice;
        uint256 contentTimestamp;
        mapping(address => uint256) collections;
    }

    struct Contributor {
        uint256 profileId;
        uint256 creatorId;
        uint256 contentId;
        address profileAddress;
        uint256 contribution;
    }

    struct QueuedRoyalty {
        uint256 creatorId;
        uint256 amount;
        address payable recipient;
    }

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition;
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition;
    }

    event FacetOperation(address indexed facetAddress, string operationType);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function setContractOwner(address _owner) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.contractOwner = _owner;
    }

    function transferOwnership(address _newOwner) external {
        enforceIsContractOwner();
        setContractOwner(_newOwner);
    }

    function enforceIsContractOwner() internal {
        DiamondStorage storage ds = diamondStorage();
        require(msg.sender == ds.contractOwner, "Must be contract owner");
    }

    function owner() external view returns (address owner_) {
        DiamondStorage storage ds = diamondStorage();
        owner_ = ds.contractOwner;
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
            // Emit the FacetOperation event
            emit FacetOperation(_diamondCut[facetIndex].facetAddress, "Operation Performed");
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

    // Ensure the initialization function checks for code size to prevent contracts without implementation
    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    // Implementation of DiamondCut, Loupe functions, and other utility functions
}