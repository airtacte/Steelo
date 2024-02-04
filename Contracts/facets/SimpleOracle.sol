pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract SimpleOracle is Ownable, ChainlinkClient {
    int256 public steezTransactionCount;
    uint256 public steeloCurrentPrice;

    constructor() {
        setChainlinkToken(0x779877a7b0d9e8603169ddbd7836e478b4624789); // Set the token to be used for paying for the oracle service
    }

    function requestVolumeData(uint256 _payment) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000, address(this), this.fulfill.selector);
        // Customize the request parameters
        req.add("get", "https://us-central1-steelo-47.cloudfunctions.net/functionName");
        req.add("path", "volume");
        sendChainlinkRequestTo(0xb83E47C2bC239B3bf370bc41e1459A34b41238D0, req, _payment);
    }

    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
        steezTransactionCount = _volume;
    }

    function getLatestPrice(address _priceFeed) public view returns (int) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_priceFeed);
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }

    function getSteezTransactionCount() external view returns (int256) {
        return steezTransactionCount;
    }

    function getSteeloCurrentPrice() external view returns (uint256) {
        return steeloCurrentPrice;
    }
}