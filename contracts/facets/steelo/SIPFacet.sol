// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Edmund Berkmann
pragma solidity ^0.8.10;

import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { ConstDiamond } from "../../libraries/ConstDiamond.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "hardhat/console.sol";

contract SIPFacet is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address sipFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    event SIPCreated(uint256 indexed id, string description, string proposalType, address indexed proposer);
    event SIPVoted(uint256 indexed id, bool support, address indexed voter, uint256 weight);
    event SIPExecuted(uint256 indexed id, bool success);

    function initialize() public initializer {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        sipFacetAddress = ds.sipFacetAddress;

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function createSIP(string memory _description, string _type, uint256 _duration) external onlyStaker nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _duration;
        uint256 newSipId = ++ds.lastSipId;
        
        ds.sips.push(LibDiamond.SIP({
            sipId: newSipId,
            description: _description,
            startTime: startTime,
            endTime: endTime,
            proposer: msg.sender,
            sipType: _type,
            voteCountFor: 0,
            voteCountAgainst: 0,
            executed: false
        }));
        
        emit SIPCreated(newSipId, _description, _type, msg.sender, startTime, endTime);
    }

    function voteOnSIP(uint256 _sipId, bool _support) external onlyStaker nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        require(_sipId < ds.lastSipId, "SIP does not exist");
        require(!sip.votes[msg.sender], "Already voted");
        require(block.timestamp >= ds.sips.startTime && block.timestamp <= ds.sips.endTime, "Voting is not active");

        uint256 weight = 1;
        if (msg.sender == sipType) {
            weight = 2;
        }

        if (_support) {
            ds.sips.voteCountFor += weight;
        } else {
            ds.sips.voteCountAgainst += weight;
        }

        emit SIPVoted(_sipId, _support, msg.sender, weight);
    }

    function checkForExecution(uint256 _sipId) internal {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();

        uint256 totalVotes = ds.sips.voteCountFor + ds.sips.voteCountAgainst;
        require(totalVotes >= 4, "Insufficient votes");

        // Execute SIP if the majority is achieved considering the initiator's double vote
        if (ds.sips.voteCountFor >= 3) {
            executeSIP(_sipId); // Assuming executeSIP function exists and handles SIP execution
        }
    }
        
    function executeSIP(uint256 _sipId) external onlyAdmin nonReentrant {
        LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
        require(_sipId < ds.sips.length, "SIP does not exist");
        require(ds.sips[_sipId].endTime < block.timestamp, "SIP voting period has not ended");
        require(!ds.sips.executed, "SIP already executed");

        // Example condition for execution; replace with actual logic specific to the SIP
        if (ds.sips.voteCountFor > ds.sips.voteCountAgainst) {
            ds.sips.executed = true;
            emit SIPExecuted(_sipId, success, reason);
        } else {
            emit SIPExecuted(_sipId, !success, reason);
        }
    }

        // Function to view SIP details
        function viewSIP(uint256 _sipId) public view returns (SIP memory) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            require(_sipId < ds.sips.length, "SIP does not exist");
            return ds.sips[_sipId];
        }

        // Function to list all SIPs
        function listSIPs() public view returns (SIP[] memory) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            return ds.sips;
        }

        function getTotalSIPs() public view returns (uint256) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            return ds.sips.length; // ideally as "success/total sips"
        }

        function getVoteCount(uint256 _sipId) public view returns (uint256) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            require(_sipId < ds.sips.length, "SIP does not exist");
            return ds.sips[_sipId].voteCountFor + ds.sips[_sipId].voteCountAgainst;
        }

        function isSIPActive(uint256 _sipId) public view returns (bool) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            require(_sipId < ds.sips.length, "SIP does not exist");
            return block.timestamp >= ds.sips[_sipId].startTime && block.timestamp <= ds.sips[_sipId].endTime;
        }

        function isSIPExecuted(uint256 _sipId) public view returns (bool) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            require(_sipId < ds.sips.length, "SIP does not exist");
            return ds.sips[_sipId].executed;
        }

        // Function to check the balance of the treasury
        function getTreasuryBalance(address _token) public view returns (uint256) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            return ds.treasury[_token];
        }

        // Function to deposit funds into the treasury
        function depositToTreasury(address _token, uint256 _amount) external onlyOwner nonReentrant {
            IERC20(_token).transferFrom(msg.sender, address(this), _amount);
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            ds.treasury[_token] += _amount;
        }

        // Function to withdraw funds from the treasury
        function withdrawFromTreasury(address _token, uint256 _amount) external onlyOwner nonReentrant {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            require(ds.treasury[_token] >= _amount, "Insufficient funds in treasury");
            ds.treasury[_token] -= _amount;
            IERC20(_token).transfer(msg.sender, _amount);
        }

        // Function to check the balance of the treasury
        function getTreasuryBalance(address _token) public view returns (uint256) {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            return ds.treasury[_token];
        }
}