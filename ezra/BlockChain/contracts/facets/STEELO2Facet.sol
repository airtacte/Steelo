// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import {AppConstants} from "../libraries/LibAppStorage.sol";
import {LibSteelo} from "../libraries/LibSteelo.sol";

contract STEELO2Facet {
   
	AppStorage internal s;

	event TokensMinted(address indexed to, uint256 amount);
    	event TokensBurned(uint256 amount);
    	event MintRateUpdated(uint256 newMintRate);
    	event BurnRateUpdated(uint256 newBurnRate);
    	event steeloTGEExecuted(uint256 tgeAmount);
    	event DeflationaryTokenomicsActivated();


	

	function calculateSupplyCap() external payable {
		LibSteelo.calculateSupplyCap();
	}

	function steeloSupplyCap() public view returns(uint256) {
		return s.supplyCap / 10 ** 18;
	}

	function adjustMintRate( uint256 amount) external {
		LibSteelo.adjustMintRate(amount);
        	emit MintRateUpdated(amount);
   	}

	function steeloMintRate() public view returns (uint256) {
		return s.mintRate / 10 ** 18;
   	}

	function adjustBurnRate( uint256 amount) external {
		LibSteelo.adjustBurnRate(amount);
        	emit BurnRateUpdated(amount);
   	}

	function steeloBurnRate() public view returns (uint256) {
		return s.burnRate;
   	}

	function burnSteeloTokens() public {
		LibSteelo.burnTokens(msg.sender);
		emit TokensBurned(s.burnAmount);	
	}

	function steeloBurnAmount() public view returns (uint256) {
		return (s.burnAmount * 100) / 10 ** 18;
   	}

	function steeloTotalBurnAmount() public view returns (uint256) {
		return s.totalBurned;
   	}

	function verifyTransaction(uint256 sipId) public {
       		LibSteelo.verifyTransaction(sipId);
    	}
    	function getVerifiedTransaction(uint256 sipId) public view returns (bool) {
		if ( s.sips[sipId].voteCountForCreator + s.sips[sipId].voteCountForCommunity + s.sips[sipId].voteCountForSteelo >= 3 ) {
        	    	return true;
        	}	
			return false;
	} 



}
