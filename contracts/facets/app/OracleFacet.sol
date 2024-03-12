// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/Chainlink.sol";

contract OracleFacet is OwnableUpgradeable, ChainlinkClient {
    address oracleFacetAddress;
    using Chainlink for Chainlink.Request;
    using LibDiamond for LibDiamond.DiamondStorage;

    // State variables for tracking transaction counts and prices
    uint256 private steezTransactionCount;
    uint256 private steeloCurrentPrice;

    // Chainlink variables for Oracle requests
    bytes32 private jobId;
    uint256 private fee;

    // Event declarations for logging oracle requests and updates
    event VolumeDataRequested(bytes32 indexed requestId, uint256 payment);
    event VolumeDataUpdated(uint256 volume);
    event PriceUpdated(address priceFeed, int256 price);

    // Function to initialize the facet
    function initialize(address chainlinkTokenAddress) public initializer {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        oracleFacetAddress = ds.oracleFacetAddress;
        
        __Ownable_init(msg.sender);
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        jobId = "yourJobIdHere"; // Replace with your Job ID
        fee = 0.1 * 10 ** 18; // (Varies by network and job)
    }
    
    // Function to request volume data from an external API using Chainlink
    function requestVolumeData(uint256 _payment, bytes32 _jobId, address _oracle) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfill.selector);
        req.add("get", "https://us-central1-steelo-47.cloudfunctions.net/functionName"); // Corrected method
        req.add("path", "volume");
        bytes32 requestId = sendChainlinkRequestTo(_oracle, req, _payment);
        emit VolumeDataRequested(requestId, _payment);
    }

    // Callback function to receive the volume data
    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
        steezTransactionCount = _volume;
        emit VolumeDataUpdated(_volume);
    }

    // Function to fetch the latest price from a Chainlink Price Feed
    function getLatestPrice(address _priceFeed) public view returns (int256 price) {
        require(_priceFeed != address(0), "Invalid price feed address");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_priceFeed);
        (, price, , , ) = priceFeed.latestRoundData();
        emit PriceUpdated(_priceFeed, price);
    }

    // Getter functions for state variables
    function getSteezTransactionCount() external view returns (uint256) {
        return steezTransactionCount;
    }

    function getSteeloCurrentPrice() external view returns (uint256) {
        return steeloCurrentPrice;
    }
}