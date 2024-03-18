// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "./AccessControlFacet.sol";
import { SIPFacet } from "../steelo/SIPFacet.sol";
import { SafeProxyFactory } from "../../../lib/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import { SafeProxy } from "../../../lib/safe-contracts/contracts/proxies/SafeProxy.sol";
import { SafeL2 } from "../../../lib/safe-contracts/contracts/SafeL2.sol";
import { ISafe } from "../../../lib/safe-contracts/contracts/interfaces/ISafe.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/Chainlink.sol";

contract MultiSigFacet is ChainlinkClient, AccessControlFacet {
    address multiSigFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;
    using Chainlink for Chainlink.Request;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}

    // Chainlink Setup
    address oracleAddress;
    uint256 fee;

    event IdentityVerification(address indexed user, bool isVerified);
    event ActivitySigned(address indexed safeAddress, address signer, bytes activityHash);
    event VoteVerified(uint256 proposalId, address signer, bool verified);
    event KYCVerificationCompleted(uint256 userId, bool isVerified);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    

    /**
     * Initialize the MultiSigFacet.
     * This function sets up the contract owner in the Diamond Storage and can include additional initialization logic as needed.
     */
    function initialize(bytes32 functionality) external onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        multiSigFacetAddress = ds.multiSigFacetAddress;

        bytes32 jobId = ds.jobIds[functionality];
        oracleAddress = ds.oracleAddresses[jobId];
        fee = ds.constants.CHAINLINK_FEE;
        chainlinkTokenAddress = ds.constants.CHAINLINK_TOKEN_ADDRESS;

        SafeProxyFactory safeProxyFactory = SafeProxyFactory(ds.safeProxyFactoryAddress());
        address safeTemplate = ds.safeTemplateAddress(); // Ensure this is added to LibDiamond and ConstDiamond
        
        // Example: Deploy a new Safe instance using the SafeProxyFactory
        // You would also include additional logic to configure the newly created Safe according to your requirements
        address[] memory owners = new address[](1);
        owners[0] = msg.sender; // Example setup with a single owner for demonstration
        uint256 threshold = 1; // Setting threshold to 1 for demonstration
        
        bytes memory data = abi.encodeWithSelector(ISafe.setup.selector, owners, threshold, address(0), "", address(0), address(0), 0, address(0));

        // Parameters for Safe creation could include more complex setup as required by your application
        address newSafeAddress = safeProxyFactory.createProxy(safeTemplate, data);
        
        // Post-deployment configuration of the Safe, such as setting owners, threshold, etc., goes here
    }

    // Function to create a new Safe with multiple owners and a specified threshold
    function createSafeWithOwners(address[] memory _owners, uint256 _threshold) public returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_owners.length >= _threshold, "Threshold cannot be higher than the number of owners");

        SafeProxyFactory safeProxyFactory = SafeProxyFactory(ds.safeProxyFactoryAddress());
        address safeTemplate = ds.safeTemplateAddress();

        bytes memory data = abi.encodeWithSelector(ISafe.setup.selector, _owners, _threshold, address(0), "", address(0), address(0), 0, address(0));
        
        SafeProxy proxy = safeProxyFactory.createProxy(safeTemplate, data);
        assert(address(proxy) != address(0));

        // Additional setup like adding modules or setting up policies can be done here

        return address(proxy);
    }

    function verifyIdentity(address user) public returns (bytes32 requestId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        Chainlink.Request memory req = buildChainlinkRequest(ds.jobIds["verifyIdentity"], address(this), this.fulfillVerification.selector);
        
        // Assuming the user's address needs to be sent as a parameter to the Trulioo API
        // This is a simplification. In practice, more user details would be needed, handled off-chain.
        req.add("userAddress", string(abi.encodePacked(user)));
        
        // Send the request to the Chainlink oracle
        requestId = sendChainlinkRequestTo(ds.oracleAddresses["Trulioo"], req, ds.chainlinkFee);
        
        // Map the request ID to the user address for tracking
        ds.verificationRequests[requestId] = user;
    }

    // Callback function for Chainlink oracle responses
    function fulfillVerification(bytes32 _requestId, bool _isVerified) public recordChainlinkFulfillment(_requestId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 userId = ds.verificationRequests[_requestId];
        emit KYCVerificationCompleted(userId, _isVerified);

        // Update the contract state based on the verification result
        if (_isVerified) {
            ds.profiles[userId].verified = true;
        }
    }

    function initiateTransaction(address from, address to, uint amount) public onlyRole(accessControl.USER_ROLE()) {
        // Use Safe-global SDK functions for multisig transaction initiation
    }
    
    function signActivity(address safeAddress, bytes memory activityHash, bytes memory signature) public returns (bool) {
        SafeL2 safe = SafeL2(safeAddress); // Assuming Safe is a contract interface for a multi-signature wallet

        // Recover the signer from the signature and activityHash
        address signer = recoverSigner(activityHash, signature);
        require(signer != address(0), "Invalid signature");
        require(ISafe(safeAddress).isOwner(signer), "Signer is not an owner");

        emit ActivitySigned(safeAddress, signer, activityHash);

        return true;
    }

    function verifyVote(uint256 proposalId, bytes memory signature, bytes memory voter) public onlyRole(accessControl.STAKER_ROLE()) returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        SIPFacet sip = SIPFacet(ds.sipFacetAddress);

        // Assuming each proposal has a unique hash that voters sign
        bytes memory proposalHash = sip.getProposalHash(proposalId);
        address signer = recoverSigner(proposalHash, signature);
        
        // Ensure the signer is an eligible voter for the proposal. This might involve checking if the signer is part of a multi-sig wallet that's allowed to vote
        require(signer != address(0), "Invalid signature");

        emit VoteVerified(proposalId, signer, true); // Log the successful verification

        return true;
    }

    function recoverSigner(bytes memory hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // ecrecover takes the keccak256 hash, recover the original hash
            return ecrecover(keccak256(hash), v, r, s);
        }
    }

    /**
     * A placeholder function to demonstrate how multisig functionality might be integrated.
     * This function and its contents should be adapted based on the specific needs of your project and the capabilities of the Safe{Core} SDK.
     */
    function exampleMultisigFunctionality() external {
        // Example functionality to illustrate integration points.
        // Actual implementation should utilize the Safe{Core} SDK for interacting with Gnosis Safe multisig features.
    }

    /**
     * Transfer ownership of the contract within the Diamond Storage.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) public onlyRole(accessControl.EXECUTIVE_ROLE()) {
        require(newOwner != address(0), "New owner cannot be the zero address");
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        
        // Revoke the EXECUTIVE_ROLE from the current owner
        accessControl.revokeRole(accessControl.EXECUTIVE_ROLE(), ds.contractOwner);

        // Grant the EXECUTIVE_ROLE to the new owner
        accessControl.grantRole(accessControl.EXECUTIVE_ROLE(), newOwner);

        ds.contractOwner = newOwner;
        emit OwnershipTransferred(ds.contractOwner, newOwner);
    }

    // Additional functions and logic for interacting with Gnosis Safe functionality can be added here.
}