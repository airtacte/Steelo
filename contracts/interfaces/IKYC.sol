// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

interface IKYC {
    function verifyUser(address user) external returns (bool);

    function getUserStatus(address user) external view returns (bool);
}
