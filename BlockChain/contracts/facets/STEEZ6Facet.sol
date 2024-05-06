// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import {LibSteez} from "../libraries/LibSteez.sol";
import {AppConstants} from "../libraries/LibAppStorage.sol";
import {Steez} from "../libraries/LibAppStorage.sol";


contract STEEZ6Facet {
   
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


    	

	

	

	function P2PBuy( string memory creatorId, uint256 buyingPrice, uint256 buyingAmount) public {
		LibSteez.P2PBuy(msg.sender, creatorId, buyingPrice, buyingAmount);
	}
	

	


}
