// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import {LibSteelo} from "../libraries/LibSteelo.sol";
import {AppConstants} from "../libraries/LibAppStorage.sol";

contract STEELO3Facet {
   
	AppStorage internal s;

	event TokensMinted(address indexed to, uint256 amount);
    	event TokensBurned(uint256 amount);
    	event MintRateUpdated(uint256 newMintRate);
    	event BurnRateUpdated(uint256 newBurnRate);
    	event steeloTGEExecuted(uint256 tgeAmount);
    	event DeflationaryTokenomicsActivated();

	function authors() public view returns (string memory) {
		return "Edmund, Ravi, Ezra, Malcom";
	}

	function steeloName () public view returns (string memory) {
		return s.name;
	}

	function steeloSymbol () public view returns (string memory) {
		return s.symbol;
	}

	function steeloDecimal () public view returns (uint256) {
		return AppConstants.decimal;
	}

	function steeloTotalSupply () public view returns (uint256 ) {
		return s.totalSupply;
	}

	

	function steeloTotalTokens() public view returns (uint256) {
		return (AppConstants.TGE_AMOUNT);
	}
	

	

	



	function steeloBurn(uint256 amount) public returns (bool) {
		amount = amount * 10 ** 18;
		LibSteelo.burn(msg.sender, amount);
		return true;
	}

	function steeloMint(uint256 amount) public returns (bool) {
		amount = amount * 10 ** 18;
		LibSteelo.mint(msg.sender, amount);
		return true;
	}


	


	function getTotalTransactionAmount() public view returns (int256) {
		return s.totalTransactionCount;
	}

	
	


	

	



}
