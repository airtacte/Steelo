// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./libraries/LibDiamond.sol";

contract SteeloMultiSigFacet {
    function initialize() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;
    }
}

            // Gnosis Safe multisig setup
            GnosisSafeProxyFactory proxyFactory = GnosisSafeProxyFactory(GNOSIS_SAFE_PROXY_FACTORY);
            GnosisSafeProxy proxy = GnosisSafeProxy(proxyFactory.createProxy(GNOSIS_SAFE_MASTER_COPY, ""));
            ISafe safe = ISafe(address(proxy));
            
            // Configure the Gnosis Safe with the given `safeAddress`
            safe.setup(
                new address[](1){safeAddress}, // The Safe owners
                1,          // The number of required confirmations
                address(0), // Address of the module that checks signatures
                bytes(""),  // Data for the module that checks signatures
                address(0), // Address of the fallback handler
                address(0), // Address of the token payment receiver
                0,          // Value of the token payment
                address(0)  // Address of the token to pay
            );
            
            // Transfer ownership of the contract to the Gnosis Safe
            transferOwnership(address(safe));