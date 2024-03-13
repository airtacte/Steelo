// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import { AccessControlFacet } from "./AccessControlFacet.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/Chainlink.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract OracleFacet is OwnableUpgradeable, ChainlinkClient, Initializable {
    address oracleFacetAddress;
    using Chainlink for Chainlink.Request;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl; // Instance of the AccessControlFacet
    constructor(address _accessControlFacetAddress) {accessControl = AccessControlFacet(_accessControlFacetAddress);}

    // State variables we aim to track via the oracle
    // steezTransactionCount;
    // steeloCurrentPrice;
    // Trulioo KYC API;

    // Event declarations for logging oracle requests and updates
    event VolumeDataRequested(bytes32 indexed requestId, uint256 payment);
    event VolumeDataUpdated(uint256 volume);
    event PriceUpdated(address priceFeed, int256 price);

    modifier onlyExecutive() {
        require(accessControl.hasRole(accessControl.EXECUTIVE_ROLE(), msg.sender), "AccessControl: caller is not an executive");
        _;
    }

    // Function to initialize the facet
    function initialize(address chainlinkTokenAddress) public onlyExecutive initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        oracleFacetAddress = ds.oracleFacetAddress;
        
        setChainlinkToken(ds.constants.CHAINLINK_TOKEN_ADDRESS); // Assuming constants are accessible this way
    }
    
    // Function to request volume data from an external API using Chainlink
    function requestVolumeData(uint256 _payment, bytes32 _jobId, address _oracle) public onlyOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfill.selector);
        req.add("get", "https://us-central1-steelo-47.cloudfunctions.net/functionName"); // Corrected method
        req.add("path", "volume");
        bytes32 requestId = sendChainlinkRequestTo(_oracle, req, _payment);
        emit VolumeDataRequested(requestId, _payment);
    }

    // Callback function to receive the volume data
    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.totalTransactionCount = _volume;
        emit VolumeDataUpdated(_volume);
    }

    // Function to fetch the latest price from a Chainlink Price Feed
    function getLatestPrice(address _priceFeed, uint256 creatorId) public view returns (int256 price) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_priceFeed != address(0), "Invalid price feed address");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_priceFeed);
        (, price, , , ) = priceFeed.latestRoundData();
        emit PriceUpdated(_priceFeed, price);
        ds.steez.currentPrice[creatorId] = uint256(price);
    }

    // Getter functions for state variables
    function getSteezTransactionCount() external view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.steezTransactionCount;
    }

    function getSteeloCurrentPrice() external view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.steeloCurrentPrice;
    }
}