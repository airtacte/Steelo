// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library AppConstants{
    	uint256 constant _NOT_ENTERED = 1;
    	uint256 constant _ENTERED = 2;
    	uint256 constant decimal = 18;
    	uint256 constant TGE_AMOUNT = 825_000_000 * 10 ** decimal;
        uint256 constant pMin = 0.5 * (10 ** 6);
        uint256 constant pMax = 5 * (10 ** 6);
        uint256 constant rho = 1 * (10 ** 6);
        uint256 constant alpha = 10;
        uint256 constant beta = 10;
        uint256 constant delta = 10;
        uint256 constant MIN_MINT_RATE = 0;
        uint256 constant MAX_MINT_RATE = 10;
        uint256 constant MIN_BURN_RATE = 0;
        uint256 constant MAX_BURN_RATE = 10;
        // Tokenomics for STEEZ
        uint256 constant AUCTION_DURATION = 24 hours;
        uint256 constant PRE_ORDER_SUPPLY = 5;
        uint256 constant LAUNCH_SUPPLY = 5;
        uint256 constant EXPANSION_SUPPLY = 10;
        uint256 constant TRANSACTION_MULTIPLIER = 2;
        uint256 constant INITIAL_PRICE = 30 ether;
        uint256 constant PRICE_INCREMENT = 10 ether;
        uint256 constant TOKEN_BATCH_SIZE = 250;
        uint256 constant PRE_ORDER_CREATOR_ROYALTYE = 90;
        uint256 constant PRE_ORDER_STEELO_ROYALTY = 10;
        uint256 constant LAUNCH_CREATOR_ROYALTY = 90;
        uint256 constant LAUNCH_STEELO_ROYALTY = 75;
        uint256 constant LAUNCH_COMMUNITY_ROYALTY = 25;
        uint256 constant  SECOND_HAND_SELLER_ROYALTY = 90;
        uint256 constant SECOND_HAND_CREATOR_ROYALTY = 50;
        uint256 constant SECOND_HAND_STEELO_ROYALTY = 25;
        uint256 constant SECOND_HAND_COMMUNITY_ROYALTY = 25;
        uint256 constant EXTRA_TOKENS_AFTER_AUCTION = 250;
        uint256 constant MAX_CREATOR_TOKENS = 5000;
        uint256 constant ANNUAL_TOKEN_INCREASE_PERCENTAGE = 10;
        // Stakeholder's royalty distribution
        address constant treasury = 0x408d4EdFBF01a23FFf57e49ed4A5126343B97cBa;
        uint256 constant trasuryTGE = 35;
        uint256 constant treasuryMint = 35;
        address constant liquidityProviders = 0x5eacB20439bED5763472D13e9b7Dc058cdAeF63f;
        uint256 constant liquidityProvidersMint = 55;
        address constant ecosystemProviders = 0x16D4b08d25F565380FC94eED43a1Eb4f34c63072;
        uint256 constant ecosystemProvidersMint = 10;
        address constant foundersAddress = 0x4d9B65B52db6D31302D77a7AF37A76A93cf03C0f;
        uint256 constant foundersTGE = 20;
        address constant earlyInvestorsAddress = 0xd1170F835c632E6a7C05d83c7D550433650F9279;
        uint256 constant earlyInvestorsTGE = 10;
        address constant communityAddress = 0x35Cb21605de10503DD4d644003DA92E3e83f69C3;
        uint256 constant communityTGE = 35;
        address constant steeloAddress = 0x45F9B54cB97970c0E798dB0FDF2b8076Cdf57d25;
        uint256 constant FEE_RATE = 25;
        address constant uniswapAddress = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        address constant gbptAddress = 0x86B4dBE5D203e634a12364C0e428fa242A3FbA98;
        // Safe Global - Addresses to be replaced
        address constant SAFE_PROXY_FACTORY_ADDRESS = 0x07720111f3d48427e55e35CB07b5D203A4edCd08;
        address constant SAFE_MASTER_COPY = 0x07720111f3d48427e55e35CB07b5D203A4edCd08;
        uint256 constant saltNonce = 1000;
        // Chainlink
        address constant CHAINLINK_TOKEN_ADDRESS = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;
        uint256 constant CHAINLINK_FEE = 0.1 ether;
        // Utility Constants
        uint256 constant oneYear = 365 days;
        uint256 constant oneWeek = 7 days;




	string constant EXECUTIVE_ROLE = "EXECUTIVE_ROLE";
    	string constant ADMIN_ROLE = "ADMIN_ROLE";
    	string constant EMPLOYEE_ROLE = "EMPLOYEE_ROLE";
    	string constant TESTER_ROLE = "TESTER_ROLE";
    	string constant STAKER_ROLE = "STAKER_ROLE";
    	string constant USER_ROLE = "USER_ROLE";
    	string constant VISITOR_ROLE = "VISITOR_ROLE";
    	string constant CREATOR_ROLE = "CREATOR_ROLE";
    	string constant TEAM_ROLE = "TEAM_ROLE";
    	string constant MODERATOR_ROLE = "MODERATOR_ROLE";
    	string constant COLLABORATOR_ROLE = "COLLABORATOR_ROLE";
    	string constant INVESTOR_ROLE = "INVESTOR_ROLE";
    	string constant SUBSCRIBER_ROLE = "SUBSCRIBER_ROLE";
}





	struct Investor {
        	uint256 investorId;
        	uint256 profileId; 
        	address walletAddress;
		uint256 steeloInvested;
		uint256 timeInvested;
        	bool isInvestor;
    	}

	struct Staker {
		uint256 amount;
		uint256 endTime;
		uint256 month;
		uint256 interest;
	}

    struct Royalty {
        uint256 creatorId; 
        uint256 totalRoyalties; 
        uint256 unclaimedRoyalties; 
        uint256 creatorRoyalties; 
        uint256 investorRoyalties; 
        uint256 steeloRoyalties; 
        mapping(uint256 => uint256) royaltyAmounts; 
        mapping(uint256 => uint256[]) royaltyPayments; 
    }


    struct Steez {
        string creatorId; 
        string steezId;
        bool creatorExists; 
        uint256 totalSupply; 
        uint256 transactionCount; 
        uint256 lastMintTime; 
        uint256 anniversaryDate; 
        uint256 currentPrice; 
        uint256 auctionStartTime; 
        uint256 auctionSlotsSecured; 
        string baseURI; 
        bool preOrderStarted;
        bool preOrderEnded;
        bool launchStarted;
        bool launchEnded;
        bool P2PStarted;
        bool AnniversaryStarted;
        uint256 preOrderStartTime;
        bool auctionConcluded;
        uint256 liquidityPool;
        uint256 totalSteeloPreOrder;
	address creatorAddress;
        Investor[] investors; 
        Royalty royalties; 
	mapping(address => uint256) SteeloInvestors;
    }


    struct Content {
        uint256 contentId;
        uint256 creatorId;
        bool exclusivity;
        string title;
        string contentURI;
        uint256 collectionPrice;
        uint256 collectionScarcity;
        uint256 uploadTimestamp;
        mapping(address => uint256) collections;
    }


    struct Contributor {
        uint256 profileId;
        uint256 creatorId;
        uint256 contentId;
        address profileAddress;
        uint256 contribution;
    }


    struct Message {
	uint256 id;
	string message;
	uint256 timeSent;
	address sender;
	address recipient;
    }

    struct Creator {
        string creatorId;
        address profileAddress;
//        mapping(uint256 => Content) content; 
//        mapping(address => Investor) investors; 
//        mapping(uint256 => Contributor[]) credits; 
	
    }

    struct Voter {
        bool voted; 
        address voter;
        bool vote;
	string role;
    }

    struct SIP {
        uint256 sipId;
        string sipType;
        string title;
        string description;
        address proposer;
        string proposerRole;
        uint256 voteCountForSteelo;
        uint256 voteCountAgainstSteelo;
        uint256 voteCountForCreator;
        uint256 voteCountAgainstCreator;
        uint256 voteCountForCommunity;
        uint256 voteCountAgainstCommunity;
        uint256 startTime;
        uint256 endTime;
        bool executed;
	string status;

//        mapping(address => bool) votes;
    }

    struct Seller {
	address sellerAddress;
	uint256 sellingPrice;
	uint256 sellingAmount;
    }

    struct CreatorSteez {
	string creatorId;
	address creatorAddress;
	uint256 steezPrice;
	uint256 totalInvestors;
    }

    struct Unstakers {
	address account;
	uint256 amount;
    }




struct AppStorage {
    string name;
    string symbol;
    uint256 totalSupply;
    uint256 _status;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowance;
    uint256 lastMintEvent;
    bool tgeExecuted;
    int256 totalTransactionCount;
    uint256 steeloCurrentPrice;
    string[] allCreatorIds;
    mapping(string => Steez) steez;
    uint256 burnAmount;
    uint256 burnRate;
    uint256 mintAmount;
    uint256 totalMinted;
    uint256 supplyCap;
    uint256 mintRate;
    uint256 totalBurned;
    uint256 lastBurnEvent;
    mapping(uint256 => SIP) sips;
    address treasury;
    bool steeloInitiated;
    uint256 mintTransactionLimit;
    mapping(address => Staker) stakers;
    Unstakers[] unstakers;
    

    string creatorTokenName;
    string creatorTokenSymbol;
    uint256 _lastCreatorId;
    uint256 _lastProfileId;
    uint256 _lastSteezId;
    string baseURI;
    mapping(string => Creator) creators;
    mapping(address => string) creatorIdentity;
    mapping( address => mapping(string => uint256)) steezInvested;
    mapping( address => mapping(string => bool)) preorderBidFinished;
    mapping ( uint256 => uint256) lastSteezId;
    CreatorSteez[] allCreators;
    bool equality;
    uint256 popInvestorIndex;
    bool bidAgain;
    bool steezInitiated;
    address popInvestorAddress;
    uint256 popInvestorPrice;
    mapping(string => Seller[]) sellers;
    bool P2PTransaction;
    address P2PSeller;
//    mapping ( string => Steez) profileSteez;
//    mapping ( string => Creator) profileCreator;


    mapping( string => mapping (address => mapping(address => Message[]))) p2pMessages;
    mapping( string => mapping(address => address[])) contacts;
    mapping( string => Message[]) posts;
    uint256 messageCounter;
   

//    mapping( uint256 => mapping(address => bool)) votes;
    uint256 _lastSIPId;
    SIP[] allSIPs;
    mapping( uint256 => mapping( address => Voter)) votes;


	mapping(address => string) roles;
        mapping(address => bool) executiveMembers;
        mapping(address => bool) adminMembers;
        mapping(address => bool) employeeMembers;
        mapping(address => bool) testerMembers;
        mapping(address => bool) stakerMembers;
        mapping(address => bool) userMembers;
        mapping(address => bool) visitorMembers;
        mapping(address => bool) creatorMembers;
        mapping(address => bool) teamMembers;
        mapping(address => bool) collaboratorMembers;
        mapping(address => bool) investorMembers;
        mapping(address => bool) moderatorMembers;
        mapping(address => bool) subscriberMembers;
	bool accessInitialized;



    
   

}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}

interface ReentrancyGuard{
    modifier nonReentrant() {
        require(LibAppStorage.diamondStorage()._status != AppConstants._ENTERED, "ReentrancyGuard: reentrant call");

        LibAppStorage.diamondStorage()._status = AppConstants._ENTERED;

        _;

        LibAppStorage.diamondStorage()._status = AppConstants._NOT_ENTERED;
    }
}
