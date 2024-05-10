    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./LibAppStorage.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AppConstants} from "./LibAppStorage.sol";
import {Creator, Steez, Investor, Seller, CreatorSteez, Content} from "./LibAppStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


library LibSteez {

	
   	modifier withinAuctionPeriod(string memory creatorId) {
        	AppStorage storage s = LibAppStorage.diamondStorage();
        	require( s.steez[creatorId].auctionStartTime != 0, "STEEZFacet: Auction hasn't started" );
        	require( block.timestamp < s.steez[creatorId].auctionStartTime + AppConstants.AUCTION_DURATION, "STEEZFacet: Auction has ended.");
	    	_;
	    }


	function initiate(address treasury) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require (s.userMembers[treasury], "you  have no steelo account");	
		require( treasury != address(0), "0 address can not initiate steez");
		require( treasury == s.treasury, "only treasurer can initiate steez");
		require( !s.steezInitiated, "steez already initiated");
		s.creatorTokenName = "Steez";
		s.creatorTokenSymbol = "STZ";	
		s.steezInitiated = true;
		
	}

	function createCreator( address creator, string memory profileId ) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require( creator != address(0), "STEEZFacet: Cannot create account for zero address" );
		require(!s.creatorMembers[creator], "already have a creator Account");
		require(keccak256(abi.encodePacked(s.creatorIdentity[creator])) == keccak256(abi.encodePacked("")), "you already have a creator account please create a creator account");
		Creator memory newCreator = Creator({
         		creatorId: profileId,
            		profileAddress: creator
        	});

//		s.stakerMembers[creator] = true;
		s.userMembers[creator] = true;
		s.visitorMembers[creator] = true;
		s.creatorMembers[creator] = true;
		s.collaboratorMembers[creator] = true;
//		s.investorMembers[creator] = true;
//		s.subscriberMembers[creator] = true;

		s.creatorIdentity[creator] = profileId;
		s.userIdentity[creator] = profileId;
		s.creators[profileId] = newCreator; 
	}

	function deleteCreator( address creator, string memory profileId ) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		require( creator != address(0), "STEEZFacet: Cannot delete to zero address" );
		require(s.creators[profileId].profileAddress == creator, "you can not delete other creators account");
		require(keccak256(abi.encodePacked(s.creatorIdentity[creator])) != keccak256(abi.encodePacked("")), "you have no creator account please create a creator account");
		s.creatorIdentity[creator] = "";
		delete s.creators[profileId];
		delete s.steez[profileId];
		uint256 length = s.allCreators.length;

		for (uint256 i = 0; i < length; i++) {
			if (s.allCreators[i].creatorAddress == creator) {
				s.allCreators[i] =  s.allCreators[length - 1];
				s.allCreators.pop();
			}
		}

		 

		 
	}


	function createSteez( address creator) internal {
			AppStorage storage s = LibAppStorage.diamondStorage();
	
		        require( creator != address(0), "STEEZFacet: Cannot mint to zero address" );
			require(keccak256(abi.encodePacked(s.creatorIdentity[creator])) != keccak256(abi.encodePacked("")), "you have no creator account please create a creator account");
//        		for (uint i = 0; i < s.allCreators.length; i++) {
//            			require( s.allCreators[i] != creator, "this address already created steez tokens");
//			}
	
			string memory creatorId = s.creatorIdentity[creator]; 
		        string memory steezId = s.creatorIdentity[creator];

			require(s.steez[creatorId].creatorAddress == address(0), "this account already has a steez");
//		        require(creatorId < type(uint256).max, "STEEZFacet: Creator overflow");
		        require( !s.steez[creatorId].creatorExists, "STEEZFacet: Token already exists");

	
		        

    			s.steez[creatorId].creatorId = creatorId;
    			s.steez[creatorId].creatorAddress = creator;
    			s.steez[creatorId].steezId = steezId;
    			s.steez[creatorId].creatorExists = true;
    			s.steez[creatorId].totalSupply = 5;
    			s.steez[creatorId].transactionCount = 0;
    			s.steez[creatorId].lastMintTime = block.timestamp;
    			s.steez[creatorId].anniversaryDate = block.timestamp + AppConstants.oneYear;
    			s.steez[creatorId].currentPrice = 30 * 10 ** 18;
    			s.steez[creatorId].auctionStartTime = block.timestamp + AppConstants.oneWeek;
    			s.steez[creatorId].auctionSlotsSecured = 0;
    			s.steez[creatorId].auctionConcluded = false;
    			s.steez[creatorId].status = "Not Initiated";

			
			CreatorSteez memory newCreatorSteez = CreatorSteez({
         			creatorId: creatorId,
            			creatorAddress: creator,
				steezPrice: s.steez[creatorId].currentPrice,
				totalInvestors: s.steez[creatorId].investors.length,
				steezStatus: s.steez[creatorId].status
        		});
			s.allCreators.push(newCreatorSteez);
	        	
	
	        	if ( s.steez[creatorId].lastMintTime == 0 || (s.steez[creatorId].lastMintTime + AppConstants.oneYear) <= block.timestamp ) { 
				s.steez[creatorId].lastMintTime = block.timestamp;
		        }
			s.mintingTransactionLimit[creatorId] = 10;
	
	    	}




		function createContent( address creator, string memory videoId, bool exclusivity) internal {
			AppStorage storage s = LibAppStorage.diamondStorage();
	
		        require( creator != address(0), "STEEZFacet: Cannot mint to zero address" );
			require(keccak256(abi.encodePacked(s.creatorIdentity[creator])) != keccak256(abi.encodePacked("")), "you have no creator account please create a creator account");
	
			string memory creatorId = s.creatorIdentity[creator]; 


		        

			
			Content memory newContent = Content({
         			creatorId: creatorId,
            			contentId: videoId,
				exclusivity: exclusivity,
				creatorAddress: creator,
				uploadTimestamp: block.timestamp
        		});

			s.creatorContent[creatorId][videoId] = newContent; 
			s.creatorCollections[creatorId].push(newContent);
			s.collections.push(newContent);
	        	
	
	        	
	
	    	}

		function deleteContent( address creator, string memory videoId ) internal {
			AppStorage storage s = LibAppStorage.diamondStorage();
			require( creator != address(0), "STEEZFacet: Cannot delete to zero address" );
			require(keccak256(abi.encodePacked(s.creatorIdentity[creator])) != keccak256(abi.encodePacked("")), "you have no creator account please create a creator account");
	
			string memory creatorId = s.creatorIdentity[creator];
			require(s.creatorContent[creatorId][videoId].creatorAddress == creator, "you can not delete other creators content");
			
			uint256 length = s.creatorCollections[creatorId].length;
	
			for (uint256 i = 0; i < length; i++) {
				if (s.creatorCollections[creatorId][i].creatorAddress == creator) {
					s.creatorCollections[creatorId][i] =  s.creatorCollections[creatorId][length - 1];
					s.creatorCollections[creatorId].pop();
				}
			}

			uint256 len = s.collections.length;
	
			for (uint256 i = 0; i < length; i++) {
				if (s.collections[i].creatorAddress == creator) {
					s.collections[i] =  s.collections[len - 1];
					s.collections.pop();
				}
			}
			delete s.creatorContent[creatorId][videoId];

		 
	}









	function preOrder( string memory creatorId, address from ) internal {
			AppStorage storage s = LibAppStorage.diamondStorage();
			 require( s.steez[creatorId].creatorAddress == from, "STEEZFacet: Only creators can initiate pre-orders.");
			 require(!s.steez[creatorId].auctionConcluded, "STEEZFacet: Auction has concluded.");
			 require(!s.steez[creatorId].preOrderStarted, "STEEZFacet: preorder has already started.");
			s.steez[creatorId].totalSupply = AppConstants.PRE_ORDER_SUPPLY;
        		s.steez[creatorId].preOrderStartTime = block.timestamp;
            		s.steez[creatorId].preOrderStarted = true;
    			s.steez[creatorId].status = "PreOrder";
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
            					s.allCreators[i].steezStatus = s.steez[creatorId].status;
            					break;
        				}
    				}
	    		
			
			mintSteez(from, creatorId, AppConstants.PRE_ORDER_SUPPLY);

        
		}

	function mintSteez( address to, string memory creatorId,  uint256 amount ) internal {
			AppStorage storage s = LibAppStorage.diamondStorage();
        		require(to != address(0), "STEEZFacet: mint to the zero address");
        		require(amount > 0, "STEEZFacet: mint amount must be positive");
        		require(amount <= 500, "STEEZFacet: mint amount must be less than 500");
        		
			s.steez[creatorId].liquidityPool += amount;
			s.totalSteezTransaction[creatorId] += 1;
    }

    	function encodeSteezId( uint256 creatorId, uint256 steezId ) internal pure returns (uint256) {
        	return (creatorId << 128) | steezId;
    	}

    	function decodeSteezId( uint256 encodedId ) internal pure returns (uint256 creatorId, uint256 steezId) {
        	creatorId = encodedId >> 128;
        	steezId = encodedId & ((1 << 128) - 1);
        	return (creatorId, steezId);
    	}


	function bidPreOrder( address investor, string memory creatorId,  uint256 amount ) internal {
			AppStorage storage s = LibAppStorage.diamondStorage();
			amount = amount * 10 ** 18;
			bool bidAgain;
			require (s.userMembers[investor], "you  have no steelo account");	
			require(s.steez[creatorId].creatorAddress != investor, "creators can not bid on thier own steez");
			require(!s.steez[creatorId].launchStarted, "Launch has started");	
			require(!s.steez[creatorId].preOrderEnded, "Preorder has ended");	
			require(amount >= s.steez[creatorId].currentPrice, "you should higher than the steez current price");
			require(keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("PreOrder")), "preorder has not started yet");
//			if (s.totalSteezTransaction[creatorId] > s.mintingTransactionLimit[creatorId]) {
//				steeloMint();
//				s.mintingTransactionLimit[creatorId] += 10;
//			}
			if ((block.timestamp > s.steez[creatorId].preOrderStartTime + 24 hours) && keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("PreOrder"))) {
    				s.steez[creatorId].status = "Approval";
				s.steez[creatorId].currentPrice = s.steez[creatorId].totalSteeloPreOrder / s.steez[creatorId].investors.length;
				for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
            					s.allCreators[i].steezPrice = s.steez[creatorId].currentPrice;
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
//						s.allCreators[i].totalInvestors = s.steez[creatorId].investors.length; 
            					break;
        				}
    				}
				s.steez[creatorId].preOrderStarted = false;
				s.steez[creatorId].preOrderEnded = true;
				require(s.steez[creatorId].preOrderEnded, "Preorder has not ended");
				require(s.steez[creatorId].liquidityPool > 0, "liquidity pool empty");
				s.steez[creatorId].totalSupply += AppConstants.LAUNCH_SUPPLY;
            			s.steez[creatorId].launchStarted = true;				
				mintSteez(s.steez[creatorId].creatorAddress, creatorId, AppConstants.LAUNCH_SUPPLY);
			}

			if (!s.steez[creatorId].launchStarted) {
		
			for (uint256 i = 0; i < s.steez[creatorId].investors.length; i++) {
				if (investor == s.steez[creatorId].investors[i].walletAddress) {
					uint256 additional =  amount - s.steez[creatorId].investors[i].steeloInvested;
					require(s.balances[investor] >= (additional), "you have insufficient balance");
					require(s.stakers[investor].amount >= ((additional) / 100), "you have insufficient staked ether");
					s.balances[investor] -= (additional);
					s.stakers[investor].amount -= (additional / 100);
//					s.stakers[s.steez[creatorId].creatorAddress].amount += (additional / 100);
//					if ( s.stakers[s.steez[creatorId].creatorAddress].endTime < s.stakers[investor].endTime) {
//						s.stakers[s.steez[creatorId].creatorAddress].endTime = s.stakers[investor].endTime;
//					}
//					if (s.stakers[s.steez[creatorId].creatorAddress].month < s.stakers[investor].month) {
//						s.stakers[s.steez[creatorId].creatorAddress].month = s.stakers[investor].month;
//					}
//					s.balances[s.steez[creatorId].creatorAddress] += additional;
					s.steez[creatorId].SteeloInvestors[investor] += (additional);
					s.steez[creatorId].totalSteeloPreOrder += (additional);
					s.steez[creatorId].investors[i].steeloInvested += (additional);
					s.totalTransactionCount += 1;

					bidAgain = true;
				}
			}

			if (bidAgain == false) {
				require(s.balances[investor] >= amount, "you have insufficient balance");
				require(s.stakers[investor].amount >= (amount / 100), "you have insufficient staked ether");

				
			
			if (  s.steez[creatorId].auctionSlotsSecured >= 5) {
				
				sortInvestors(creatorId);
				findPopInvestor(creatorId);
				require( amount >= (s.steez[creatorId].investors[s.popInvestorIndex].steeloInvested + (10 * 10 ** 18)), "should have a higher bid to continue" );
				removeInvestor(creatorId);
				s.steez[creatorId].auctionSlotsSecured -= 1;

			}

			s.balances[investor] -= amount;
			s.stakers[investor].amount -= (amount / 100);
//			s.stakers[s.steez[creatorId].creatorAddress].amount += (amount / 100);
//			if ( s.stakers[s.steez[creatorId].creatorAddress].endTime < s.stakers[investor].endTime) {
//				s.stakers[s.steez[creatorId].creatorAddress].endTime = s.stakers[investor].endTime;
//			}
//			if (s.stakers[s.steez[creatorId].creatorAddress].month < s.stakers[investor].month) {
//				s.stakers[s.steez[creatorId].creatorAddress].month = s.stakers[investor].month;
//			}
//			s.balances[s.steez[creatorId].creatorAddress] += amount;
			s.steez[creatorId].SteeloInvestors[investor] = amount;
			s.steez[creatorId].totalSteeloPreOrder += amount;

			s.steez[creatorId].auctionSlotsSecured += 1;
			s.totalTransactionCount += 1;

			 Investor memory newInvestor = Investor({
            			investorId: s.steez[creatorId].investors.length,
            			profileId: 1,
            			walletAddress: investor,
            			steeloInvested: amount,
            			timeInvested: block.timestamp,
            			isInvestor: true
        		});
        		s.steez[creatorId].investors.push(newInvestor);
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
						s.allCreators[i].totalInvestors = s.steez[creatorId].investors.length; 
            					break;
        				}
    				}
			}
			bidAgain = false;

			}
			
    }




    function sortInvestors(string memory creatorId) internal {
    	AppStorage storage s = LibAppStorage.diamondStorage();
    	uint length = s.steez[creatorId].investors.length;
	Investor memory temp;
    
    	for (uint i = 0; i < length; i++) {
		for (uint j = 0; j < length - i - 1; j++) {
			if (s.steez[creatorId].investors[j].steeloInvested > s.steez[creatorId].investors[j + 1].steeloInvested) {
				temp = s.steez[creatorId].investors[j];
				s.steez[creatorId].investors[j] =  s.steez[creatorId].investors[j + 1];
				s.steez[creatorId].investors[j + 1] = temp;

			}
		}
		

    		}
	}

	
	function findPopInvestor(string memory creatorId) internal {
    		AppStorage storage s = LibAppStorage.diamondStorage();
    		uint length = s.steez[creatorId].investors.length;

		if (length == 0) return;

		uint256 max = s.steez[creatorId].investors[0].timeInvested;
		s.popInvestorIndex = 0;
        
        	for (uint i = 1; i < length && (s.steez[creatorId].investors[i - 1].steeloInvested == s.steez[creatorId].investors[i].steeloInvested); i++) {
            	if (s.steez[creatorId].investors[i].timeInvested > max ) {
			max =  s.steez[creatorId].investors[i].timeInvested;
                	s.popInvestorIndex = i;
            	}
        	}



        	
	}

	function removeInvestor(string memory creatorId) internal {
    		AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.popInvestorIndex < s.steez[creatorId].investors.length, "index out of bounds");
		s.balances[s.steez[creatorId].investors[s.popInvestorIndex].walletAddress] += s.steez[creatorId].investors[s.popInvestorIndex].steeloInvested;
		s.steez[creatorId].SteeloInvestors[s.steez[creatorId].investors[s.popInvestorIndex].walletAddress] -= s.steez[creatorId].investors[s.popInvestorIndex].steeloInvested;
		s.steez[creatorId].totalSteeloPreOrder -= s.steez[creatorId].investors[s.popInvestorIndex].steeloInvested; 
    		uint length = s.steez[creatorId].investors.length;
		s.steez[creatorId].investors[s.popInvestorIndex] =  s.steez[creatorId].investors[length - 1];
		s.steez[creatorId].investors.pop();
		s.totalTransactionCount += 1;

		
	}

	function PreOrderEnder(string memory creatorId) internal {
    		AppStorage storage s = LibAppStorage.diamondStorage();
//		sortInvestors(creatorId);
//		findPopInvestor(creatorId);
//		require( amount >= (s.steez[creatorId].investors[s.popInvestorIndex].steeloInvested + (10 * 10 ** 18)), "should have a higher bid to continue" );
		s.steez[creatorId].preOrderStartTime -= 25 hours;
		

	}

	function AcceptOrReject(address investor, string memory creatorId, bool answer) internal {
    		AppStorage storage s = LibAppStorage.diamondStorage();
		require (s.userMembers[investor], "you  have no steelo account");	
		require(s.steez[creatorId].SteeloInvestors[investor] > 0, "you have not bid any amount");
		require(!s.preorderBidFinished[investor][creatorId], "you have finished bidding for your preorder finished");
		if ((block.timestamp > s.steez[creatorId].preOrderStartTime + 24 hours) && keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("PreOrder"))) {
    				s.steez[creatorId].status = "Approval";
				s.steez[creatorId].currentPrice = s.steez[creatorId].totalSteeloPreOrder / s.steez[creatorId].investors.length;
				for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
            					s.allCreators[i].steezPrice = s.steez[creatorId].currentPrice;
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
//						s.allCreators[i].totalInvestors = s.steez[creatorId].investors.length; 
            					break;
        				}
    				}
				s.steez[creatorId].preOrderStarted = false;
				s.steez[creatorId].preOrderEnded = true;
				require(s.steez[creatorId].preOrderEnded, "Preorder has not ended");
				require(s.steez[creatorId].liquidityPool > 0, "liquidity pool empty");
				s.steez[creatorId].totalSupply += AppConstants.LAUNCH_SUPPLY;
            			s.steez[creatorId].launchStarted = true;				
				mintSteez(s.steez[creatorId].creatorAddress, creatorId, AppConstants.LAUNCH_SUPPLY);
		}
		require(s.steez[creatorId].launchStarted, "approval has not started");
		require(keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("Approval")), "approval has not started yet");
		if (s.totalSteezTransaction[creatorId] > s.mintingTransactionLimit[creatorId]) {
				steeloMint();
				s.mintingTransactionLimit[creatorId] += 10;
			}
		if (block.timestamp >= s.steez[creatorId].auctionStartTime && keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("Approval"))) {
			s.steez[creatorId].status = "Launch";
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
            					break;
        				}
    				}
		}
		for (uint256 i = 0; i < s.steez[creatorId].investors.length; i++) {
				if (investor == s.steez[creatorId].investors[i].walletAddress) {
					if (s.steez[creatorId].currentPrice > s.steez[creatorId].investors[i].steeloInvested) {
						uint256 additional = s.steez[creatorId].currentPrice - s.steez[creatorId].investors[i].steeloInvested; 
						if (answer && (s.balances[investor] >= additional)) {
							s.balances[investor] -= additional;
							s.stakers[investor].amount -= (additional / 100);
							s.steez[creatorId].SteeloInvestors[investor] += additional;
							s.steez[creatorId].investors[i].steeloInvested += additional;
							s.steez[creatorId].totalSteeloPreOrder += additional;
							s.stakers[s.steez[creatorId].creatorAddress].amount += ((s.steez[creatorId].currentPrice * 90) / 10000 );
							s.stakers[s.treasury].amount += ((s.steez[creatorId].currentPrice * 10) / 10000 );
							if ( s.stakers[s.steez[creatorId].creatorAddress].endTime < s.stakers[investor].endTime) {
								s.stakers[s.steez[creatorId].creatorAddress].endTime = s.stakers[investor].endTime;
							}
							if (s.stakers[s.steez[creatorId].creatorAddress].month < s.stakers[investor].month) {
								s.stakers[s.steez[creatorId].creatorAddress].month = s.stakers[investor].month;
							}
							s.balances[s.steez[creatorId].creatorAddress] += (s.steez[creatorId].currentPrice * 90) / 100;
							s.balances[s.treasury] += (s.steez[creatorId].currentPrice * 10) / 100;
							s.steezInvested[investor][creatorId] += 1;
							s.steez[creatorId].liquidityPool -= 1;
							s.preorderBidFinished[investor][creatorId] = true;
							s.totalTransactionCount += 1;
							s.totalSteezTransaction[creatorId] += 1;
						}
						else {
							s.balances[investor] += s.steez[creatorId].investors[i].steeloInvested;
							s.stakers[investor].amount += (s.steez[creatorId].investors[i].steeloInvested / 100);
                                                        s.steez[creatorId].SteeloInvestors[investor] -=  s.steez[creatorId].investors[i].steeloInvested;
							s.steez[creatorId].totalSteeloPreOrder -= s.steez[creatorId].investors[i].steeloInvested;
							s.steez[creatorId].investors[i].steeloInvested -= s.steez[creatorId].investors[i].steeloInvested;
							s.steez[creatorId].auctionSlotsSecured -= 1;
							s.preorderBidFinished[investor][creatorId] = true;
							s.totalTransactionCount += 1;
						}
					}
					else {
						uint256 refund = s.steez[creatorId].investors[i].steeloInvested - s.steez[creatorId].currentPrice; 
						if (answer) {
							s.balances[investor] += refund;
							s.stakers[investor].amount += (refund / 100);
							s.steez[creatorId].SteeloInvestors[investor] -= refund;
							s.steez[creatorId].totalSteeloPreOrder -= refund;	
							s.steez[creatorId].investors[i].steeloInvested -= refund;
							s.stakers[s.steez[creatorId].creatorAddress].amount += ((s.steez[creatorId].currentPrice * 90) / 10000 );
							if ( s.stakers[s.steez[creatorId].creatorAddress].endTime < s.stakers[investor].endTime) {
								s.stakers[s.steez[creatorId].creatorAddress].endTime = s.stakers[investor].endTime;
							}
							if (s.stakers[s.steez[creatorId].creatorAddress].month < s.stakers[investor].month) {
								s.stakers[s.steez[creatorId].creatorAddress].month = s.stakers[investor].month;
							}
							s.balances[s.steez[creatorId].creatorAddress] += (s.steez[creatorId].currentPrice * 90) / 100;
							s.steezInvested[investor][creatorId] += 1;
							s.steez[creatorId].liquidityPool -= 1;
							s.preorderBidFinished[investor][creatorId] = true;
							s.totalTransactionCount += 1;
							s.totalSteezTransaction[creatorId] += 1;
						}
						else {
							s.balances[investor] += s.steez[creatorId].investors[i].steeloInvested;
							s.stakers[investor].amount += (s.steez[creatorId].investors[i].steeloInvested / 100);
                                                        s.steez[creatorId].SteeloInvestors[investor] -=  s.steez[creatorId].investors[i].steeloInvested;
							s.steez[creatorId].totalSteeloPreOrder -= s.steez[creatorId].investors[i].steeloInvested;
							s.steez[creatorId].investors[i].steeloInvested -= s.steez[creatorId].investors[i].steeloInvested;
							s.steez[creatorId].auctionSlotsSecured -= 1;
							s.preorderBidFinished[investor][creatorId] = true;
							s.totalTransactionCount += 1;
						}
					}
				}
			}
		
		
	}

	function launchStarter(string memory creatorId) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.steez[creatorId].auctionStartTime -= AppConstants.oneWeek;	
	}

	function bidLaunch(address investor, string memory creatorId, uint256 amount) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		bool bidAgain;
		require (s.userMembers[investor], "you  have no steelo account");	
		require(s.steez[creatorId].creatorAddress != investor, "creators can not bid on thier own steez");
		require(s.steez[creatorId].launchStarted, "Launch has not started");
		require(!s.steez[creatorId].launchEnded, "Launch has ended");
		require(s.balances[investor] >= (s.steez[creatorId].currentPrice * amount), "you have insufficient balance");
		require(amount > 0 && amount <= 5, "amount of steez per person is between 1 and 5");
		require(s.steez[creatorId].liquidityPool - amount >= 0, "liquidity pool has insufficient steez");
		if (block.timestamp >= s.steez[creatorId].auctionStartTime && keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("Approval"))) {
			s.steez[creatorId].status = "Launch";
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
            					break;
        				}
    			}
		}
		require(block.timestamp >= s.steez[creatorId].auctionStartTime, "launch has not started yet");
		require(keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("Launch")), "launch has not started yet");
		if (s.totalSteezTransaction[creatorId] > s.mintingTransactionLimit[creatorId]) {
				steeloMint();
				s.mintingTransactionLimit[creatorId] += 10;
			}

		for (uint256 i = 0; i < s.steez[creatorId].investors.length; i++) {
				if (investor == s.steez[creatorId].investors[i].walletAddress) {
					bidAgain = true;
					require(s.steezInvested[investor][creatorId] + amount <= 5, "amount of steez per person is from 1 up to 5");
				}
			}

		s.balances[investor] -= (s.steez[creatorId].currentPrice * amount);
		s.balances[s.steez[creatorId].creatorAddress] += (s.steez[creatorId].currentPrice * amount * 90) /100;
		s.balances[s.treasury] += (s.steez[creatorId].currentPrice * amount * 75) /1000;
		s.stakers[investor].amount -= ((s.steez[creatorId].currentPrice * amount) / 100);
		s.stakers[s.steez[creatorId].creatorAddress].amount += ((s.steez[creatorId].currentPrice * amount * 90) / 10000);
		s.stakers[s.treasury].amount += ((s.steez[creatorId].currentPrice * amount * 75) / 100000);
		for (uint256 i = 0; i < s.steez[creatorId].investors.length; i++) {
			s.balances[s.steez[creatorId].investors[i].walletAddress] += (s.steez[creatorId].currentPrice * amount * 25) /10000;
			s.stakers[s.steez[creatorId].investors[i].walletAddress].amount += ((s.steez[creatorId].currentPrice * amount * 25) / 1000000);
			
		}
			if ( s.stakers[s.steez[creatorId].creatorAddress].endTime < s.stakers[investor].endTime) {
				s.stakers[s.steez[creatorId].creatorAddress].endTime = s.stakers[investor].endTime;
			}
			if (s.stakers[s.steez[creatorId].creatorAddress].month < s.stakers[investor].month) {
				s.stakers[s.steez[creatorId].creatorAddress].month = s.stakers[investor].month;
			}
		s.steez[creatorId].SteeloInvestors[investor] = (s.steez[creatorId].currentPrice);
		s.steez[creatorId].totalSteeloPreOrder += (s.steez[creatorId].currentPrice * amount);
		s.steezInvested[investor][creatorId] += amount;

		s.steez[creatorId].auctionSlotsSecured += 1;
		s.totalTransactionCount += 1;
    		s.steez[creatorId].liquidityPool -= amount;
		s.totalSteezTransaction[creatorId] += 1;

		if (bidAgain == false) {

			 Investor memory newInvestor = Investor({
         			investorId: s.steez[creatorId].investors.length,
            			profileId: 1,
            			walletAddress: investor,
            			steeloInvested: (s.steez[creatorId].currentPrice * amount),
            			timeInvested: block.timestamp,
            			isInvestor: true
        		});
        		s.steez[creatorId].investors.push(newInvestor);
		}
		
		s.steez[creatorId].currentPrice = ((75 * s.steez[creatorId].currentPrice) / 100) + ( (25 * (s.steez[creatorId].liquidityPool > 0 ? s.steez[creatorId].totalSteeloPreOrder / s.steez[creatorId].liquidityPool : s.steez[creatorId].currentPrice)) / 100);



		for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
            					s.allCreators[i].steezPrice = s.steez[creatorId].currentPrice;
						s.allCreators[i].totalInvestors = s.steez[creatorId].investors.length; 
            					break;
        				}
    				}
		


		
		if (s.steez[creatorId].liquidityPool == 0) {
			s.steez[creatorId].launchEnded = true;
			s.steez[creatorId].P2PStarted = true;
    			s.steez[creatorId].status = "P2P";
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
            					break;
        				}
    			}
		} 

	}
	

	function initiateP2PSell(address seller , string memory creatorId, uint256 sellingPrice, uint256 steezAmount) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		bool sellAgain;
		sellingPrice *= 10 ** 18;
		require (s.userMembers[seller], "you  have no steelo account");	
		require(steezAmount > 0 && steezAmount <= 5 , "steez has to be between 1 and 5");
		require(s.steezInvested[seller][creatorId] >= steezAmount, "you have insufficient steez tokens to sell");
		if (block.timestamp > s.steez[creatorId].anniversaryDate && keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("P2P"))) {
			s.steez[creatorId].P2PStarted = false;
			s.steez[creatorId].AnniversaryStarted = true;
    			s.steez[creatorId].status = "Anniversary";
			s.steez[creatorId].totalSupply += AppConstants.EXPANSION_SUPPLY;
			mintSteez(s.steez[creatorId].creatorAddress, creatorId, AppConstants.EXPANSION_SUPPLY);
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
            					break;
        				}
    			}
		}
		require(keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("P2P")), "preorder has not started yet");

		for (uint256 i = 0; i < s.sellers[creatorId].length; i++) {
					if (seller == s.sellers[creatorId][i].sellerAddress) {
						sellAgain = true;
						require(s.sellers[creatorId][i].sellingAmount + steezAmount <= 5, "amount of steez per person is from 1 up to 5");
						s.sellers[creatorId][i].sellingPrice =  sellingPrice;
						s.sellers[creatorId][i].sellingAmount = steezAmount;
					}
				}
	
		if (sellAgain == false) {
			Seller memory newSeller = Seller({
					sellerAddress: seller,
					sellingPrice: sellingPrice,
					sellingAmount: steezAmount
        			});
        			s.sellers[creatorId].push(newSeller);
		}


	}

	function P2PBuy(address buyer, string memory creatorId, uint256 buyingPrice, uint256 buyingAmount) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		bool bidAgain;
		require (s.userMembers[buyer], "you  have no steelo account");	
		require(s.steez[creatorId].P2PStarted, "Peer to Peer transaction not allowed yet");
		require(keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("P2P")), "p2p has not started yet");
		if (s.totalSteezTransaction[creatorId] > s.mintingTransactionLimit[creatorId]) {
				steeloMint();
				s.mintingTransactionLimit[creatorId] += 10;
			}
		if (block.timestamp > s.steez[creatorId].anniversaryDate && keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("P2P"))) {
			s.steez[creatorId].P2PStarted = false;
			s.steez[creatorId].AnniversaryStarted = true;
    			s.steez[creatorId].status = "Anniversary";
			s.steez[creatorId].totalSupply += AppConstants.EXPANSION_SUPPLY;
			mintSteez(s.steez[creatorId].creatorAddress, creatorId, AppConstants.EXPANSION_SUPPLY);
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
            					break;
        				}
    			}
		}

		if (s.steez[creatorId].P2PStarted) {


		buyingPrice *= 10 ** 18;
		require(buyingAmount > 0, "can not buy 0 steez");
		require(s.balances[buyer] > buyingPrice * buyingAmount, "has insufficient steelo tokens");
		require(s.steezInvested[buyer][creatorId] + buyingAmount <= 5, "can not own more than 5 steez tokens");
		
		if (buyingAmount == s.steez[creatorId].currentPrice) {
			s.steez[creatorId].currentPrice = s.steez[creatorId].currentPrice;
		}
		else if (buyingPrice > s.steez[creatorId].currentPrice) {
			s.steez[creatorId].currentPrice += (buyingPrice - s.steez[creatorId].currentPrice) / 10;
		}
		else if (buyingPrice < s.steez[creatorId].currentPrice) {
			s.steez[creatorId].currentPrice -= (s.steez[creatorId].currentPrice - buyingPrice) / 10;
		}

		for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
            					s.allCreators[i].steezPrice = s.steez[creatorId].currentPrice;
						s.allCreators[i].totalInvestors = s.steez[creatorId].investors.length; 
            					break;
        				}
    				}
		bool P2PTransaction = false;
		address P2PSeller;

		for (uint256 i = 0; i < s.sellers[creatorId].length; i++) {	
			if (buyingPrice == s.sellers[creatorId][i].sellingPrice && buyingAmount <= s.sellers[creatorId][i].sellingAmount) {
				s.balances[s.sellers[creatorId][i].sellerAddress] += (buyingPrice * buyingAmount * 90) / 100;
				s.balances[s.treasury] += (buyingPrice * buyingAmount * 25) / 1000;
				s.balances[s.steez[creatorId].creatorAddress] += (buyingPrice * buyingAmount * 50) / 1000;
				s.balances[buyer] -= (buyingPrice * buyingAmount);
				s.stakers[buyer].amount -= ((buyingPrice * buyingAmount) / 100);
				s.stakers[s.sellers[creatorId][i].sellerAddress].amount += ((buyingPrice * buyingAmount * 90) / 10000);
				s.stakers[s.treasury].amount += ((buyingPrice * buyingAmount * 25) / 100000);
				s.stakers[s.steez[creatorId].creatorAddress].amount += ((buyingPrice * buyingAmount * 50) / 100000);
				if ( s.stakers[s.sellers[creatorId][i].sellerAddress].endTime < s.stakers[buyer].endTime) {
					s.stakers[s.sellers[creatorId][i].sellerAddress].endTime = s.stakers[buyer].endTime;
				}
				if (s.stakers[s.sellers[creatorId][i].sellerAddress].month < s.stakers[buyer].month) {
					s.stakers[s.sellers[creatorId][i].sellerAddress].month = s.stakers[buyer].month;
				}
				s.steezInvested[buyer][creatorId] += buyingAmount;
				
				s.steezInvested[s.sellers[creatorId][i].sellerAddress][creatorId] -= buyingAmount;
				s.totalSteezTransaction[creatorId] += 1;

				for (uint256 i = 0; i < s.steez[creatorId].investors.length; i++) {
					if (buyer == s.steez[creatorId].investors[i].walletAddress) {
						bidAgain = true;
						s.steez[creatorId].investors[i].steeloInvested +=  (buyingPrice * buyingAmount);
						s.steez[creatorId].investors[i].timeInvested = block.timestamp;
						require(s.steezInvested[buyer][creatorId] + buyingAmount <= 5, "amount of steez per person is from 1 up to 5");
					}
				}
				
				P2PTransaction = true;
				P2PSeller = s.sellers[creatorId][i].sellerAddress;

				if (bidAgain == false) {
					Investor memory newInvestor = Investor({
        					investorId: s.steez[creatorId].investors.length,
          					profileId: 1,
            					walletAddress: buyer,
            					steeloInvested: (buyingPrice * buyingAmount),
            					timeInvested: block.timestamp,
            					isInvestor: true
        				});
        				s.steez[creatorId].investors.push(newInvestor);
				}
				for (uint256 j = 0; j < s.steez[creatorId].investors.length; j++) {
					if (s.steez[creatorId].investors[j].walletAddress == s.sellers[creatorId][i].sellerAddress) {
						if (s.steezInvested[s.sellers[creatorId][i].sellerAddress][creatorId] == 0) {
							s.steez[creatorId].SteeloInvestors[s.sellers[creatorId][i].sellerAddress] = 0;
							uint length = s.steez[creatorId].investors.length;
							s.steez[creatorId].investors[j] =  s.steez[creatorId].investors[length - 1];
							s.steez[creatorId].investors.pop();
							s.totalTransactionCount += 1;	
						}	
						else {
						s.steez[creatorId].investors[j].steeloInvested -= (buyingPrice * buyingAmount);
						s.totalTransactionCount += 1;	
						
						}
					}
				}
				break;
				
			}
		}
			if (P2PTransaction) {
				for (uint256 k = 0; k < s.sellers[creatorId].length; k++) {
					if (s.sellers[creatorId][k].sellerAddress == P2PSeller && s.sellers[creatorId][k].sellingAmount == buyingAmount) {
							uint length = s.sellers[creatorId].length;
							s.sellers[creatorId][k] =  s.sellers[creatorId][length - 1];
							s.sellers[creatorId].pop();
//							s.totalTransactionCount += 1;
							break;
					}
					else if (s.sellers[creatorId][k].sellerAddress == P2PSeller && s.sellers[creatorId][k].sellingAmount != buyingAmount ) {
						s.sellers[creatorId][k].sellingAmount -= buyingAmount;	
						break;
					}
				}

		}
	   }

	}

	function anniversaryStarter(string memory creatorId) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.steez[creatorId].anniversaryDate -= 365 days;	
	}





	function bidAnniversary(address investor, string memory creatorId, uint256 amount) internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		bool bidAgain;
		require (s.userMembers[investor], "you  have no steelo account");	
		require(s.steez[creatorId].creatorAddress != investor, "creators can not bid on thier own steez");
		require(s.balances[investor] >= (s.steez[creatorId].currentPrice * amount), "you have insufficient balance");
		require(amount > 0 && amount <= 5, "amount of steez per person is between 1 and 5");
		require(s.steez[creatorId].liquidityPool - amount >= 0, "liquidity pool has insufficient steez");
		if (block.timestamp > s.steez[creatorId].anniversaryDate && keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("P2P"))) {
			s.steez[creatorId].P2PStarted = false;
			s.steez[creatorId].AnniversaryStarted = true;
    			s.steez[creatorId].status = "Anniversary";
			s.steez[creatorId].totalSupply += AppConstants.EXPANSION_SUPPLY;
			mintSteez(s.steez[creatorId].creatorAddress, creatorId, AppConstants.EXPANSION_SUPPLY);
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
            					break;
        				}
    			}
		}
		require(block.timestamp >= s.steez[creatorId].anniversaryDate, "anniversary has not started yet");
		require(keccak256(abi.encodePacked(s.steez[creatorId].status)) == keccak256(abi.encodePacked("Anniversary")), "anniversary has not started yet");
		if (s.totalSteezTransaction[creatorId] > s.mintingTransactionLimit[creatorId]) {
				steeloMint();
				s.mintingTransactionLimit[creatorId] += 10;
			}

		for (uint256 i = 0; i < s.steez[creatorId].investors.length; i++) {
				if (investor == s.steez[creatorId].investors[i].walletAddress) {
					require(s.steezInvested[investor][creatorId] + amount <= 5, "amount of steez per person is from 1 up to 5");
					bidAgain = true;
				}
			}

		s.balances[investor] -= (s.steez[creatorId].currentPrice * amount);
		s.balances[s.steez[creatorId].creatorAddress] += (s.steez[creatorId].currentPrice * amount * 90) /100;
		s.balances[s.treasury] += (s.steez[creatorId].currentPrice * amount * 75) /1000;
		s.stakers[investor].amount -= ((s.steez[creatorId].currentPrice * amount) / 100);
		s.stakers[s.steez[creatorId].creatorAddress].amount += ((s.steez[creatorId].currentPrice * amount * 90) / 10000);
		s.stakers[s.treasury].amount += ((s.steez[creatorId].currentPrice * amount * 75) / 100000);
		for (uint256 i = 0; i < s.steez[creatorId].investors.length; i++) {
			s.balances[s.steez[creatorId].investors[i].walletAddress] += (s.steez[creatorId].currentPrice * amount * 25) /10000;
			s.stakers[s.steez[creatorId].investors[i].walletAddress].amount += ((s.steez[creatorId].currentPrice * amount * 25) / 1000000);
			
		}
			if ( s.stakers[s.steez[creatorId].creatorAddress].endTime < s.stakers[investor].endTime) {
				s.stakers[s.steez[creatorId].creatorAddress].endTime = s.stakers[investor].endTime;
			}
			if (s.stakers[s.steez[creatorId].creatorAddress].month < s.stakers[investor].month) {
				s.stakers[s.steez[creatorId].creatorAddress].month = s.stakers[investor].month;
			}
		s.steez[creatorId].SteeloInvestors[investor] = (s.steez[creatorId].currentPrice);
		s.steez[creatorId].totalSteeloPreOrder += (s.steez[creatorId].currentPrice * amount);
		s.steezInvested[investor][creatorId] += amount;

		s.steez[creatorId].auctionSlotsSecured += 1;
		s.totalSteezTransaction[creatorId] += 1;
		s.totalTransactionCount += 1;
   		s.steez[creatorId].liquidityPool -= amount;

		if (bidAgain == false) {

			 Investor memory newInvestor = Investor({
        			investorId: s.steez[creatorId].investors.length,
          			profileId: 1,
            			walletAddress: investor,
            			steeloInvested: (s.steez[creatorId].currentPrice * amount),
            			timeInvested: block.timestamp,
            			isInvestor: true
        		});
        		s.steez[creatorId].investors.push(newInvestor);

		}
		s.steez[creatorId].currentPrice = ((75 * s.steez[creatorId].currentPrice) / 100) + ( (25 * (s.steez[creatorId].liquidityPool > 0 ? s.steez[creatorId].totalSteeloPreOrder / s.steez[creatorId].liquidityPool : s.steez[creatorId].currentPrice)) / 100);


		for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
            					s.allCreators[i].steezPrice = s.steez[creatorId].currentPrice;
						s.allCreators[i].totalInvestors = s.steez[creatorId].investors.length; 
            					break;
        				}
    				}
		
		if (s.steez[creatorId].liquidityPool == 0) {
			s.steez[creatorId].P2PStarted = true;
    			s.steez[creatorId].status = "P2P";
			s.steez[creatorId].anniversaryDate += block.timestamp + 365 days;
			for (uint i = 0; i < s.allCreators.length; i++) {
        				if (keccak256(abi.encodePacked(s.allCreators[i].creatorId)) == keccak256(abi.encodePacked(creatorId))) {
						s.allCreators[i].steezStatus = s.steez[creatorId].status;
            					break;
        				}
    			}
		} 

	}

	function steeloMint() internal {
		AppStorage storage s = LibAppStorage.diamondStorage();
		s.mintAmount = calculateGenerationMintAmount();
		require( s.totalTransactionCount > 0,"STEELOFacet: s.totalTransactionCount must be greater than 0");
        	require(s.steeloCurrentPrice > 0,"STEELOFacet: steeloCurrentPrice must be greater than 0");

		uint256 treasuryAmount = (s.mintAmount * AppConstants.treasuryMint) / 100;
        	uint256 liquidityProvidersAmount = (s.mintAmount * AppConstants.liquidityProvidersMint) / 100;
        	uint256 ecosystemProvidersAmount = (s.mintAmount * AppConstants.ecosystemProvidersMint) / 100;

		


	       	s.totalMinted += s.mintAmount;
	       	s.lastMintEvent = block.timestamp;

        	mint(s.treasury, treasuryAmount);
        	mint(AppConstants.liquidityProviders, liquidityProvidersAmount);
        	mint(AppConstants.ecosystemProviders, ecosystemProvidersAmount);



		for (uint256 i = 0; i < s.unstakers.length; i++) {
			s.balances[AppConstants.liquidityProviders] -= ((s.balances[s.unstakers[i].account] * s.stakers[s.unstakers[i].account].interest)/10000);
			s.balances[s.unstakers[i].account] += ((s.balances[s.unstakers[i].account] * s.stakers[s.unstakers[i].account].interest)/10000);
			s.stakers[s.unstakers[i].account].amount +=  ((s.stakers[s.unstakers[i].account].amount * s.stakers[s.unstakers[i].account].interest)/10000);
			

			require(s.balances[s.unstakers[i].account] >= (s.unstakers[i].amount * 100), "you have used your staked steelo token for something else");
			require(s.stakers[s.unstakers[i].account].amount >= (s.unstakers[i].amount), "you have used your staked pound for something else");




	        	(bool success, ) = s.unstakers[i].account.call{value: ( s.unstakers[i].amount)}("");
	                require(success, "Transfer failed.");
			s.stakers[s.unstakers[i].account].amount -= (s.unstakers[i].amount);
			if (s.stakers[s.unstakers[i].account].amount == 0) {
				s.stakers[s.unstakers[i].account].interest = 0;	
			}
			s.balances[s.unstakers[i].account] -= (s.unstakers[i].amount * 100);
			if ( i == s.unstakers.length - 1) {
				s.steeloCurrentPrice -= ((s.steeloCurrentPrice * 1) / 10000);
			}
		}

		delete s.unstakers;

		


        	
		
     }

     function mint(address from, uint256 amount) internal {
	        AppStorage storage s = LibAppStorage.diamondStorage();
		require(s.adminMembers[from], "only admins can mint steelo tokens");
//		require(amount > 0, "can not mint 0 amount");
//		require(amount <= 825000000 * 10 ** 18, "can not mint more than 825 million tokens");
	        s.balances[from] += amount;
		s.totalSupply += amount;
		s.totalTransactionCount += 1;
		s.totalMinted += amount;
	}

	 function calculateGenerationMintAmount() public returns (uint256) {
		AppStorage storage s = LibAppStorage.diamondStorage();
		uint256 adjustmentFactor = 1 * (10 ** 6);
        	if (s.steeloCurrentPrice >= AppConstants.pMax) {
            		adjustmentFactor += (((s.steeloCurrentPrice - AppConstants.pMax) * AppConstants.alpha) / 100);
        	} else if (s.steeloCurrentPrice <= AppConstants.pMin) {
            		adjustmentFactor -= (((AppConstants.pMin - s.steeloCurrentPrice) * AppConstants.beta) / 100);
        	} else {
            		adjustmentFactor += adjustmentFactor / 100;
        	}
        	s.mintAmount = (AppConstants.rho * uint256(s.totalTransactionCount) * adjustmentFactor) / 10 ** 11;
		s.mintAmount *= 10 ** 18;

        	return s.mintAmount;
    }
	 
		


	
	
	

}
