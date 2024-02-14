// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity 0.8.20;

import { LibDiamond } from "../../libraries/LibDiamond.sol";

contract OfflineModeFacet {
    function setOfflineMode(bool _offlineMode) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.Storage storage ds = LibDiamond.diamondStorage();
        ds.offlineMode = _offlineMode;
    }
}