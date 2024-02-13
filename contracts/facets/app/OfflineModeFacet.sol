// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { LibDiamond } from "../libraries/LibDiamond.sol";

contract OfflineModeFacet {
    function setOfflineMode(bool _offlineMode) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.Storage storage ds = LibDiamond.diamondStorage();
        ds.offlineMode = _offlineMode;
    }
}