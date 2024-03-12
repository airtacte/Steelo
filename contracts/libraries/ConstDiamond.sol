// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "./LibDiamond.sol";
import { AccessControlFacet } from "../facets/app/AccessControlFacet.sol";

contract ConstDiamond {
    address constDiamondAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    // Event for logging constant updates
    event ConstantUpdated(string indexed constantName, uint256 oldValue, uint256 newValue);
    event AddressUpdated(string indexed constantName, address oldValue, address newValue);

    function initConstants() external {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        // STEELO TOKENOMICS
        ds.constants.TGE_AMOUNT = 825_000_000 * 10**18; // Immutable constant
        ds.constants.pMin = 0.5 ether;
        ds.constants.pMax = 5 ether;
        ds.constants.rho = 1 ether;
        ds.constants.alpha = 10;
        ds.constants.beta = 10;
        ds.constants.MIN_MINT_RATE = 0.5 ether;
        ds.constants.MAX_MINT_RATE = 5 ether;
        ds.constants.MIN_BURN_RATE = 0 ether;
        ds.constants.MAX_BURN_RATE = 5.5 ether;

        // STEEZ TOKENOMICS
        ds.constants.AUCTION_DURATION = 24 hours;
        ds.constants.PRE_ORDER_SUPPLY = 250;
        ds.constants.LAUNCH_SUPPLY = 250;
        ds.constants.EXPANSION_SUPPLY = 500;
        ds.constants.TRANSACTION_MULTIPLIER = 2;
        ds.constants.INITIAL_PRICE = 30 ether;
        ds.constants.PRICE_INCREMENT = 10 ether;
        ds.constants.TOKEN_BATCH_SIZE = 250;
        ds.constants.PRE_ORDER_CREATOR_ROYALTY = 90;
        ds.constants.PRE_ORDER_STEELO_ROYALTY = 10;
        ds.constants.LAUNCH_CREATOR_ROYALTY = 90;
        ds.constants.LAUNCH_STEELO_ROYALTY = 75;
        ds.constants.LAUNCH_COMMUNITY_ROYALTY = 25;
        ds.constants.SECOND_HAND_SELLER_ROYALTY = 90;
        ds.constants.SECOND_HAND_CREATOR_ROYALTY = 50;
        ds.constants.SECOND_HAND_STEELO_ROYALTY = 25;
        ds.constants.SECOND_HAND_COMMUNITY_ROYALTY = 25;

        // STAKEHOLDER'S ROYALTY DISTRIBUTION
        ds.constants.treasury = 0x07720111f3d48427e55e35CB07b5D203A4edCd08; 
        ds.constants.trasuryTGE = 35; 
        ds.constants.treasuryMint = 35;
        ds.constants.liquidityProviders = 0x22a909748884b504bb3BDC94FAE155aaa917416D; 
        ds.constants.liquidityProvidersMint = 55;
        ds.constants.ecosystemProviders = 0x5dBfD5E645FF0714dc71c3cbcADAAdf163d5971D; 
        ds.constants.ecosystemProvidersMint = 10;
        ds.constants.foundersAddress = 0x0620F316431EE739a1c1EeD54980aF5EAF5B8E49; 
        ds.constants.foundersTGE = 20;
        ds.constants.earlyInvestorsAddress = 0x6Eaa165659fbd96C10DBad3C3A89396225aEEde8; 
        ds.constants.earlyInvestorsTGE = 10;
        ds.constants.communityAddress = 0xB6912a7F733287BE95Aca28E1C563FA3Ed0BeFde; 
        ds.constants.communityTGE = 35;
        ds.constants.steeloAddresss = 0x45F9B54cB97970c0E798dB0FDF2b8076Cdf57d25;  
        ds.constants.FEE_RATE = 25;
        ds.constants.uniswapAddress = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984; 
        ds.constants.gbptAddress = 0x86B4dBE5D203e634a12364C0e428fa242A3FbA98; 

        // UTILITY CONSTANTS
        ds.constants.oneYear = 365 days; // Setup AccessControl to enforce Immutability
        ds.constants.oneWeek = 7 days; // Setup AccessControl to enforce Immutability
    }

    // STEELO TOKENOMICS

        // uint256 constant pMin = 0.5 ether;
        function updatePMin(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.pMin;
            ds.constants.pMin = _newAmount;
            emit ConstantUpdated("pMin", oldAmount, _newAmount);
        }

        // uint256 constant pMax = 5 ether;
        function updatePMax(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.pMax;
            ds.constants.pMax = _newAmount;
            emit ConstantUpdated("pMax", oldAmount, _newAmount);
        }

        // uint256 constant rho = 1 ether;
        function updateRho(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.rho;
            ds.constants.rho = _newAmount;
            emit ConstantUpdated("rho", oldAmount, _newAmount);
        }

        // uint256 constant alpha = 10;
        function updateAlpha(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.alpha;
            ds.constants.alpha = _newAmount;
            emit ConstantUpdated("alpha", oldAmount, _newAmount);
        }

        // uint256 constant beta = 10;
        function updateBeta(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.beta;
            ds.constants.beta = _newAmount;
            emit ConstantUpdated("beta", oldAmount, _newAmount);
        }

        // uint256 constant MIN_MINT_RATE = 0.5 ether;
        function updateMinMintRate(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.MIN_MINT_RATE;
            ds.constants.MIN_MINT_RATE = _newAmount;
            emit ConstantUpdated("MIN_MINT_RATE", oldAmount, _newAmount);
        }

        // uint256 constant MAX_MINT_RATE = 5 ether;
        function updateMaxMintRate(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.MAX_MINT_RATE;
            ds.constants.MAX_MINT_RATE = _newAmount;
            emit ConstantUpdated("MAX_MINT_RATE", oldAmount, _newAmount);
        }

        // uint256 constant MIN_BURN_RATE = 0 ether;
        function updateMinBurnRate(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.MIN_BURN_RATE;
            ds.constants.MIN_BURN_RATE = _newAmount;
            emit ConstantUpdated("MIN_BURN_RATE", oldAmount, _newAmount);
        }

        // uint256 constant MAX_BURN_RATE = 5.5 ether;
        function updateMaxBurnRate(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.MAX_BURN_RATE;
            ds.constants.MAX_BURN_RATE = _newAmount;
            emit ConstantUpdated("MAX_BURN_RATE", oldAmount, _newAmount);
        }

    // STEEZ TOKENOMICS

        // uint256 constant AUCTION_DURATION = 24 hours;
        function updateAuctionDuration(uint256 _newDuration) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldDuration = ds.constants.AUCTION_DURATION;
            ds.constants.AUCTION_DURATION = _newDuration;
            emit ConstantUpdated("AUCTION_DURATION", oldDuration, _newDuration);
        }

        // uint256 constant PRE_ORDER_SUPPLY = 250;
        function updatePreOrderSupply(uint256 _newSupply) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldSupply = ds.constants.PRE_ORDER_SUPPLY;
            ds.constants.PRE_ORDER_SUPPLY = _newSupply;
            emit ConstantUpdated("PRE_ORDER_SUPPLY", oldSupply, _newSupply);
        }
        
        // uint256 constant LAUNCH_SUPPLY = 250;
        function updateLaunchSupply(uint256 _newSupply) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldSupply = ds.constants.LAUNCH_SUPPLY;
            ds.constants.LAUNCH_SUPPLY = _newSupply;
            emit ConstantUpdated("LAUNCH_SUPPLY", oldSupply, _newSupply);
        }        
        
        // uint256 constant EXPANSION_SUPPLY = 500;
        function updateExpansionSupply(uint256 _newSupply) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldSupply = ds.constants.EXPANSION_SUPPLY;
            ds.constants.EXPANSION_SUPPLY = _newSupply;
            emit ConstantUpdated("EXPANSION_SUPPLY", oldSupply, _newSupply);
        }        
        
        // uint256 constant TRANSACTION_MULTIPLIER = 2;
        function updateTransactionMultiplier(uint256 _newMultiplier) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldMultiplier = ds.constants.TRANSACTION_MULTIPLIER;
            ds.constants.TRANSACTION_MULTIPLIER = _newMultiplier;
            emit ConstantUpdated("TRANSACTION_MULTIPLIER", oldMultiplier, _newMultiplier);
        }        
        
        // uint256 constant INITIAL_PRICE = 30 ether;
        function updateInitialPrice(uint256 _newPrice) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldPrice = ds.constants.INITIAL_PRICE;
            ds.constants.INITIAL_PRICE = _newPrice;
            emit ConstantUpdated("INITIAL_PRICE", oldPrice, _newPrice);
        }        
        
        // uint256 constant PRICE_INCREMENT = 10 ether;
        function updatePriceIncrement(uint256 _newIncrement) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldIncrement = ds.constants.PRICE_INCREMENT;
            ds.constants.PRICE_INCREMENT = _newIncrement;
            emit ConstantUpdated("PRICE_INCREMENT", oldIncrement, _newIncrement);
        }        
        
        // uint256 constant TOKEN_BATCH_SIZE = 250;
        function updateTokenBatchSize(uint256 _newSize) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldSize = ds.constants.TOKEN_BATCH_SIZE;
            ds.constants.TOKEN_BATCH_SIZE = _newSize;
            emit ConstantUpdated("TOKEN_BATCH_SIZE", oldSize, _newSize);
        }        
        
        // uint256 constant PRE_ORDER_CREATOR_ROYALTY = 90;
        function updatePreOrderCreatorRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.PRE_ORDER_CREATOR_ROYALTY;
            ds.constants.PRE_ORDER_CREATOR_ROYALTY = _newRoyalty;
            emit ConstantUpdated("PRE_ORDER_CREATOR_ROYALTY", oldRoyalty, _newRoyalty);
        }        
        
        // uint256 constant PRE_ORDER_STEELO_ROYALTY = 10;
        function updatePreOrderSteeloRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.PRE_ORDER_STEELO_ROYALTY;
            ds.constants.PRE_ORDER_STEELO_ROYALTY = _newRoyalty;
            emit ConstantUpdated("PRE_ORDER_STEELO_ROYALTY", oldRoyalty, _newRoyalty);
        }        
        
        // uint256 constant LAUNCH_CREATOR_ROYALTY = 90;
        function updateLaunchCreatorRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.LAUNCH_CREATOR_ROYALTY;
            ds.constants.LAUNCH_CREATOR_ROYALTY = _newRoyalty;
            emit ConstantUpdated("LAUNCH_CREATOR_ROYALTY", oldRoyalty, _newRoyalty);
        }        
                
        // uint256 constant LAUNCH_STEELO_ROYALTY = 75;
        function updateLaunchSteeloRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.LAUNCH_STEELO_ROYALTY;
            ds.constants.LAUNCH_STEELO_ROYALTY = _newRoyalty;
            emit ConstantUpdated("LAUNCH_STEELO_ROYALTY", oldRoyalty, _newRoyalty);
        }       
        
        // uint256 constant LAUNCH_COMMUNITY_ROYALTY = 25;
        function updateLaunchCommunityRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.LAUNCH_COMMUNITY_ROYALTY;
            ds.constants.LAUNCH_COMMUNITY_ROYALTY = _newRoyalty;
            emit ConstantUpdated("LAUNCH_COMMUNITY_ROYALTY", oldRoyalty, _newRoyalty);
        }        
        
        // uint256 constant SECOND_HAND_SELLER_ROYALTY = 90;
        function updateSecondHandSellerRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.SECOND_HAND_SELLER_ROYALTY;
            ds.constants.SECOND_HAND_SELLER_ROYALTY = _newRoyalty;
            emit ConstantUpdated("SECOND_HAND_SELLER_ROYALTY", oldRoyalty, _newRoyalty);
        }        
        
        // uint256 constant SECOND_HAND_CREATOR_ROYALTY = 50;
        function updateSecondHandCreatorRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.SECOND_HAND_CREATOR_ROYALTY;
            ds.constants.SECOND_HAND_CREATOR_ROYALTY = _newRoyalty;
            emit ConstantUpdated("SECOND_HAND_CREATOR_ROYALTY", oldRoyalty, _newRoyalty);
        }        
        
        // uint256 constant SECOND_HAND_STEELO_ROYALTY = 25;
        function updateSecondHandSteeloRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.SECOND_HAND_STEELO_ROYALTY;
            ds.constants.SECOND_HAND_STEELO_ROYALTY = _newRoyalty;
            emit ConstantUpdated("SECOND_HAND_STEELO_ROYALTY", oldRoyalty, _newRoyalty);
        }        
        
        // uint256 constant SECOND_HAND_COMMUNITY_ROYALTY = 25;
        function updateSecondHandCommunityRoyalty(uint256 _newRoyalty) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRoyalty = ds.constants.SECOND_HAND_COMMUNITY_ROYALTY;
            ds.constants.SECOND_HAND_COMMUNITY_ROYALTY = _newRoyalty;
            emit ConstantUpdated("SECOND_HAND_COMMUNITY_ROYALTY", oldRoyalty, _newRoyalty);
        }

    // STAKEHOLDER'S ROYALTY DISTRIBUTION
        
        
        // address constant treasury = 0x07720111f3d48427e55e35CB07b5D203A4edCd08; 
        function updateTreasury(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.treasury;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.treasury = _newAddress;
            emit AddressUpdated("treasury", oldAddress, _newAddress);
        }
        
        // uint256 constant trasuryTGE = 35; 
        function updateTrasuryTGE(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.trasuryTGE;
            ds.constants.trasuryTGE = _newAmount;
            emit ConstantUpdated("trasuryTGE", oldAmount, _newAmount);
        }
        
        // uint256 constant treasuryMint = 35;
        function updateTreasuryMint(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.treasuryMint;
            ds.constants.treasuryMint = _newAmount;
            emit ConstantUpdated("treasuryMint", oldAmount, _newAmount);
        }        
        
        // address constant liquidityProviders = 0x22a909748884b504bb3BDC94FAE155aaa917416D; 
        function updateLiquidityProviders(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.liquidityProviders;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.liquidityProviders = _newAddress;
            emit AddressUpdated("liquidityProviders", oldAddress, _newAddress);
        }
        
        // uint256 constant liquidityProvidersMint = 55;
        function updateLiquidityProvidersMint(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.liquidityProvidersMint;
            ds.constants.liquidityProvidersMint = _newAmount;
            emit ConstantUpdated("liquidityProvidersMint", oldAmount, _newAmount);
        }        
        
        // address constant ecosystemProviders = 0x5dBfD5E645FF0714dc71c3cbcADAAdf163d5971D; 
        function updateEcosystemProviders(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.ecosystemProviders;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.ecosystemProviders = _newAddress;
            emit AddressUpdated("ecosystemProviders", oldAddress, _newAddress);
        }        
        
        // uint256 constant ecosystemProvidersMint = 10;
        function updateEcosystemProvidersMint(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.ecosystemProvidersMint;
            ds.constants.ecosystemProvidersMint = _newAmount;
            emit ConstantUpdated("ecosystemProvidersMint", oldAmount, _newAmount);
        }        
        
        // address constant foundersAddress = 0x0620F316431EE739a1c1EeD54980aF5EAF5B8E49; 
        function updateFoundersAddress(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.foundersAddress;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.foundersAddress = _newAddress;
            emit AddressUpdated("foundersAddress", oldAddress, _newAddress);
        }        
        
        // uint256 constant foundersTGE = 20;
        function updateFoundersTGE(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.foundersTGE;
            ds.constants.foundersTGE = _newAmount;
            emit ConstantUpdated("foundersTGE", oldAmount, _newAmount);
        }        
        
        // address constant earlyInvestorsAddress = 0x6Eaa165659fbd96C10DBad3C3A89396225aEEde8; 
        function updateEarlyInvestorsAddress(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.earlyInvestorsAddress;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.earlyInvestorsAddress = _newAddress;
            emit AddressUpdated("earlyInvestorsAddress", oldAddress, _newAddress);
        }       
        
        // uint256 constant earlyInvestorsTGE = 10;
        function updateEarlyInvestorsTGE(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.earlyInvestorsTGE;
            ds.constants.earlyInvestorsTGE = _newAmount;
            emit ConstantUpdated("earlyInvestorsTGE", oldAmount, _newAmount);
        }        
        
        // address constant communityAddress = 0xB6912a7F733287BE95Aca28E1C563FA3Ed0BeFde; 
        function updateCommunityAddress(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.communityAddress;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.communityAddress = _newAddress;
            emit AddressUpdated("communityAddress", oldAddress, _newAddress);
        }       
        
        // uint256 constant communityTGE = 35;
        function updateCommunityTGE(uint256 _newAmount) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldAmount = ds.constants.communityTGE;
            ds.constants.communityTGE = _newAmount;
            emit ConstantUpdated("communityTGE", oldAmount, _newAmount);
        }        
        
        // address constant steeloAddresss = 0x45F9B54cB97970c0E798dB0FDF2b8076Cdf57d25;  
        function updateSteeloAddresss(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.steeloAddresss;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.steeloAddresss = _newAddress;
            emit AddressUpdated("steeloAddresss", oldAddress, _newAddress);
        }        
        
        // uint256 constant FEE_RATE = 25;
        function updateFEE_RATE(uint256 _newRate) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            uint256 oldRate = ds.constants.FEE_RATE;
            ds.constants.FEE_RATE = _newRate;
            emit ConstantUpdated("FEE_RATE", oldRate, _newRate);
        }        
        
        // address constant uniswapAddress = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984; 
        function updateUniswapAddress(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.uniswapAddress;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.uniswapAddress = _newAddress;
            emit AddressUpdated("uniswapAddress", oldAddress, _newAddress);
        }        
        
        // address constant gbptAddress = 0x86B4dBE5D203e634a12364C0e428fa242A3FbA98; 
        function updateGbptAddress(address _newAddress) external {
            LibDiamond.DiamondStorage storage ds =  LibDiamond.diamondStorage();
            address oldAddress = ds.constants.gbptAddress;
            require(_newAddress != address(0), "New address cannot be zero address");
            ds.constants.gbptAddress = _newAddress;
            emit AddressUpdated("gbptAddress", oldAddress, _newAddress);
        }
}