// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../../libraries/LibDiamond.sol";
import "../../interfaces/ISafe.sol";

contract MultiSigFacet {
    function initialize() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;

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

    function createMultiSigForTokenHolders(address[] memory holders) external {
    // Create a new array to hold the owners of the multisig wallet
    address[] memory owners = new address[](holders.length);

    // Iterate over the token holders
    for (uint i = 0; i < holders.length; i++) {
        // Check if the address holds the token
        if (steezToken.balanceOf(holders[i]) > 0) {
            // If the address holds the token, add it to the owners array
            owners[i] = holders[i];
        }
    }

    // Create the multisig wallet
    GnosisSafeProxyFactory proxyFactory = GnosisSafeProxyFactory(GNOSIS_SAFE_PROXY_FACTORY);
    GnosisSafeProxy proxy = GnosisSafeProxy(proxyFactory.createProxy(GNOSIS_SAFE_MASTER_COPY, ""));
    ISafe safe = ISafe(address(proxy));

    // Configure the Gnosis Safe with the owners
    safe.setup(
        owners,     // The Safe owners
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

    }

    function transferOwnership(address newOwner) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = newOwner;
    }

    // Store the Safe address in a mapping with the Village as the key
    villageSafes[village] = address(safe);
}