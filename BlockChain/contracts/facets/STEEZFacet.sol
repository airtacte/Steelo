// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import {LibSteez} from "../libraries/LibSteez.sol";
import {AppConstants} from "../libraries/LibAppStorage.sol";
import {Steez} from "../libraries/LibAppStorage.sol";


contract STEEZFacet {
   
	AppStorage internal s;

    event NewSteez(address indexed creatorId, bytes indexed data);
    event TokenMinted(
        uint256 indexed creatorId,
        address indexed investors,
        uint256 amount
    );
    event PreOrderMinted(
        uint256 indexed creatorId,
        address indexed investors,
        uint256 amount
    );
    event auctionConcluded(
        uint256 creatorId,
        uint256 currentPrice,
        uint256 totalSupply
    );
    event LaunchCreated(
        uint256 indexed creatorId,
        uint256 currentPrice,
        uint256 totalSupply
    );
    event LaunchMinted(
        uint256 indexed creatorId,
        uint256 currentPrice,
        address indexed investors,
        uint256 amount
    );
    event AnniversaryMinted(
        uint256 indexed creatorId,
        uint256 totalSupply,
        uint256 currentPrice,
        address indexed investors,
        uint256 amount
    );
    event SteezTransfer(
        address indexed from,
        address indexed to,
        uint256 indexed steezId,
        uint256 amount,
        uint256 royaltyAmount
    );


    	function steezInitiate () public returns (bool success) {
		LibSteez.initiate(msg.sender);
		return true;
	}

	function creatorTokenName () public view returns (string memory) {
		return s.creatorTokenName;
	}

	function creatorTokenSymbol () public view returns (string memory) {
		return s.creatorTokenSymbol;
	}

	function createSteez( ) public {
		LibSteez.createSteez( msg.sender );
    	}

	function getAllCreator(string memory creatorId) public view returns (address, uint256, uint256 ) {
		return (s.steez[creatorId].creatorAddress, s.steez[creatorId].totalSupply, s.steez[creatorId].currentPrice );
	}

	function getAllCreator2(string memory creatorId) public view returns (uint256, uint256, bool ) {
		return (s.steez[creatorId].auctionStartTime, s.steez[creatorId].anniversaryDate, s.steez[creatorId].auctionConcluded );
	}

	function initializePreOrder(string memory creatorId ) public payable {
		LibSteez.preOrder( creatorId, msg.sender );
    	}

	function getAllCreator3(string memory creatorId) public view returns (uint256, uint256, bool ) {
		return (s.steez[creatorId].preOrderStartTime, s.steez[creatorId].liquidityPool, s.steez[creatorId].preOrderStarted );
	}

	function bidPreOrder(string memory creatorId, uint256 amount) public payable {
		LibSteez.bidPreOrder( msg.sender, creatorId, amount );
		
	}

	function checkBidAmount(string memory creatorId) public view returns (uint256, uint256, uint256, uint256 ) {
		return (s.steez[creatorId].SteeloInvestors[msg.sender], s.steez[creatorId].liquidityPool, s.steez[creatorId].auctionSlotsSecured, s.steez[creatorId].totalSteeloPreOrder );
	}

	function checkInvestors(string memory creatorId) public view returns (uint256, uint256, uint256, address ) {
		return s.steez[creatorId].investors.length > 0
        		? (s.steez[creatorId].investors.length, 
           		s.steez[creatorId].investors[0].steeloInvested, 
           		s.steez[creatorId].investors[0].timeInvested, 
           		s.steez[creatorId].investors[0].walletAddress)
        		: (0, 0, 0, address(0));
	}

	

	

	function checkInvestorsLength(string memory creatorId) public view returns (uint256) {
		return s.steez[creatorId].investors.length;
	}

	function PreOrderEnder(string memory creatorId, uint256 amount) public {
		LibSteez.PreOrderEnder( msg.sender, creatorId, amount );
		
	}
	
	function AcceptOrReject(string memory creatorId, bool answer) public {
		LibSteez.AcceptOrReject( msg.sender, creatorId, answer );
		
	}

	


}
