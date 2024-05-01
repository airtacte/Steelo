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
		return s.supplyCap;
	}

	function adjustMintRate( uint256 amount) external {
		LibSteelo.adjustMintRate(amount);
        	emit MintRateUpdated(amount);
   	}

	function steeloMintRate() public view returns (uint256) {
		return s.mintRate;
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
		return (s.burnAmount * 100);
   	}

	function steeloTotalBurnAmount() public view returns (uint256) {
		return s.totalBurned;
   	}

	function steeloTotalMintAmount() public view returns (uint256) {
		return s.totalMinted;
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
	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function stakePeriodEnder(uint256 month) public {
       		LibSteelo.stakePeriodEnder(msg.sender, month);
		
	}

	function getStakedBalance() public view returns (uint256) {
		return s.stakers[msg.sender].amount;
	}

	function withdrawEther(uint256 amount) external payable returns (bool) {
		amount *= 10 ** 18;
		require(s.executiveMembers[msg.sender], "only executive can withdraw Ether from the contract");
		require(address(this).balance >= ((amount)), "no ether is available in the contract balance");
               (bool success, ) = msg.sender.call{value: amount}("");
                require(success, "Transfer failed.");
		return true;
	}

	function donateEther() external payable returns (bool) {
		LibSteelo.donateEther(msg.sender, msg.value);
		return true;
		
	}



}
