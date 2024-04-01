// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "./AccessControlFacet.sol";
import "../../interfaces/IKYC.sol";

abstract contract KYCFacet is IKYC, AccessControlFacet {
    address kycFacetAddress;
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
        kycFacetAddress = ds.kycFacetAddress;
    }

    // Simulated KYC check - in a real scenario, this would involve off-chain processes
    function verifyUser(
        uint256 profileId
    ) external onlyRole(accessControl.EMPLOYEE_ROLE()) returns (bool) {
        // Trulioo KYC API Calls TBC
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.profiles[profileId].verified = true;
        return true;
    }

    function getUserStatus(uint256 profileId) external view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.profiles[profileId].verified;
    }
}
