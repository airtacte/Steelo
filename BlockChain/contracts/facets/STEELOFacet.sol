// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import {LibSteelo} from "../libraries/LibSteelo.sol";
import {AppConstants} from "../libraries/LibAppStorage.sol";

contract STEELOFacet {
   
	AppStorage internal s;

	event TokensMinted(address indexed to, uint256 amount);
    	event TokensBurned(uint256 amount);
    	event MintRateUpdated(uint256 newMintRate);
    	event BurnRateUpdated(uint256 newBurnRate);
    	event steeloTGEExecuted(uint256 tgeAmount);
    	event DeflationaryTokenomicsActivated();

	function authors() public returns (string memory) {
		return "Edmund, Ravi, Ezra, Malcom";
	}


	function steeloInitiate () public returns (bool success) {
		LibSteelo.initiate(msg.sender);
		emit TokensMinted(msg.sender, AppConstants.TGE_AMOUNT);
		return true;
	}

	function steeloTGE() external returns (bool) {
		LibSteelo.TGE(msg.sender);
		emit TokensMinted(msg.sender, AppConstants.TGE_AMOUNT);
        	emit steeloTGEExecuted(AppConstants.TGE_AMOUNT);
		return true;
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

	
	function steeloBalanceOf(address account) public view returns (uint256) {
		return (s.balances[account]);
	}

	function steeloTransfer(address to, uint256 amount) public returns (bool) {
		amount = amount * 10 ** 18;
		LibSteelo.transfer(msg.sender, to, amount);
		return true;
			
	}

	function steeloAllowance(address owner, address spender) public view returns (uint256) {
        	return (s.allowance[owner][spender]);
   	}

	function steeloApprove(address spender, uint256 amount) public returns (bool success) {
		amount = amount * 10 ** 18;
		LibSteelo.approve(msg.sender, spender, amount);	
		return true;
	}

	function steeloTransferFrom(address from, address to, uint256 amount) public returns (bool) {
		amount = amount * 10 ** 18;
		LibSteelo.transferFrom(from, to, amount);
		return true;
			
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

	function stakeSteelo(uint256 month) public payable returns (bool){
		LibSteelo.stake(msg.sender, msg.value, month);
		return true;
        }
    	

	function unstakeSteelo(uint256 amount) external payable returns (bool) {
		amount *= 10 ** 18;
		amount /= 100;
		require(address(this).balance >= ((amount)), "no ether is available in the treasury of contract balance");
		require(s.balances[msg.sender] >= amount, "not sufficient steelo tokens to sell");
		require(s.stakers[msg.sender].amount >= amount, "you are asking more amount of ether than you staked");
		require(block.timestamp >= s.stakers[msg.sender].endTime, "you can not unstake until your staking period is over");
               (bool success, ) = msg.sender.call{value: amount}("");
                require(success, "Transfer failed.");
		LibSteelo.unstake(msg.sender, amount);
		return true;
	}


	function calculateTotalTransactionAmount() public payable {
		LibSteelo.getTotalTransactionAmount();
	}


	function getTotalTransactionAmount() public view returns (int256) {
		return s.totalTransactionCount;
	}

	function createRandomTransaction() public payable {
		LibSteelo.createRandomTransaction();
	}

	function steeloMintAdvanced() external payable{
		LibSteelo.steeloMint(msg.sender);
		emit TokensMinted(msg.sender, s.mintAmount);
	}

	


	

	



}
