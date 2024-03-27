// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import "./libraries/LibDiamond.sol";
import "./interfaces/IDiamondLoupe.sol";
import "./interfaces/IDiamondCut.sol";
import "./interfaces/IERC173.sol";
import "../lib/safe-contracts/contracts/interfaces/ISafe.sol";
import "../lib/safe-contracts/contracts/interfaces/IERC165.sol";

contract Diamond {
    struct DiamondArgs {
        address owner;
    }

    constructor(
        IDiamondCut.FacetCut[] memory _diamondCut,
        DiamondArgs memory _args,
        address _diamondLoupeFacet
    ) payable {
        // Prepare the DiamondLoupeFacet cut (assuming you have the address and function selectors)
        // This is a simplified example. You would dynamically prepare this based on the actual facets and selectors.
        IDiamondCut.FacetCut[] memory initialCut = new IDiamondCut.FacetCut[](
            _diamondCut.length + 1
        );
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            initialCut[i] = _diamondCut[i];
        }

        // Assuming diamondLoupeFacet is the address of your DiamondLoupeFacet contract
        // and diamondLoupeSelectors are the selectors for the functions in DiamondLoupeFacet
        address diamondLoupeFacet = _diamondLoupeFacet;
        bytes4[] memory diamondLoupeSelectors = new bytes4[](4); // Example: populate with actual function selectors
        diamondLoupeSelectors[0] = IDiamondLoupe.facets.selector;
        diamondLoupeSelectors[1] = IDiamondLoupe
            .facetFunctionSelectors
            .selector;
        diamondLoupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        diamondLoupeSelectors[3] = IDiamondLoupe.facetAddress.selector;

        initialCut[_diamondCut.length] = IDiamondCut.FacetCut({
            facetAddress: diamondLoupeFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: diamondLoupeSelectors
        });

        // Perform the diamond cut with the initial setup including DiamondLoupeFacet
        LibDiamond.diamondCut(initialCut, address(0), new bytes(0));

        // Set contract owner
        LibDiamond.setContractOwner(_args.owner);

        // Initialize DiamondStorage
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // Adding ERC165 data and other interfaces
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // Additional setup for DiamondLoupeFacet if needed
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(
            facet != address(0),
            "Diamond: Function does not exist - check facet assignment"
        );
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}
