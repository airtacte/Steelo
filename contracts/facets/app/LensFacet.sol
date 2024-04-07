// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "./AccessControlFacet.sol";

contract LensFacet is AccessControlFacet {
    address lensFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl;

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    function initialize()
        external
        onlyRole(accessControl.EXECUTIVE_ROLE())
        initializer
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        lensFacetAddress = ds.lensFacetAddress;
    }

    function createProfile() external {
            LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
            // Checking and creating Lens profile
        if (ds.profiles[walletAddress].exists) {
            // Logic for when a profile already exists
        } else {
            ILensHub.CreateProfileParams memory params = ILensHub.CreateProfileParams({
                to: walletAddress,
                handle: "newHandle", // Ensure this handle is unique and follows Lens Protocol requirements
                imageURI: "", // Optional: Add a valid URI if available
                followModule: address(0), // Set to the appropriate follow module address if used
                followModuleInitData: "", // Follow module initialization data if needed
                followNFTURI: "" // URI for the follow NFT if used
            });
            uint256 profileId = lensHub.createProfile(params);
            // After successful creation, store the new profileId with the corresponding walletAddress in your storage
            ds.profiles[walletAddress] = ProfileStruct({exists: true, profileId: profileId}); // Assuming a struct to store the profile data
        }
    }
}