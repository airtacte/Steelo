// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "../app/AccessControlFacet.sol";

contract ContentFacet is AccessControlFacet {
    address contentFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl;

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    event ContentUploaded(uint256 creatorId, uint256 contentId, bool exclusivity) 

    function initialize()
        external
        onlyRole(accessControl.EXECUTIVE_ROLE())
        initializer
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        contentFacetAddress = ds.contentFacetAddress;
    }

    // Function to create a new content item
    function createContent(
        string calldata _title,
        string calldata _contentURI,
        bool calldata exclusivity
    ) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require{
            msg.sender == ds.creatorExists,
            "ContentFacet: Content Uploader is not a Creator"
        };

        uint256 lastContentId;
        ds.contents[contentId] = ds.contents[contentId].creatorId & "-" & lastContentId++;
        // to be reviewed - goal is contentId = "creatorId - lastContentId++"

        ds.contents[contentId].title = _title;
        ds.contents[contentId].contentURI = _contentURI;
        ds.contents[contentId].exclusivity = _exclusivity;
        ds.contents[contentId].uploadTimestamp = block.timestamp;

        ds.creatorId = ds.creator[msg.sender].creatorId;

        emit ContentUploaded(ds.contents[creatorId].title, ds.contents[contentId].contentURI, ds.contents[contentId].exclusivity, ds.contents[contentId].uploadTimestamp)
    }

    // transform exclusive content into collectible content
    function createCollection(
        uint256 calldata _contentId,
        string calldata _contentURI,
        uint256 _collectionPrice,
        uint256 _collectionScarcity
    ) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require{
            _collectionPrice >= 0 &&
                ds.contents[exclusivity] == true,
            "ContentFacet: Selected Content Price cannot be set"
        };
        require{
            _collectionScarcity > 0 && 
                ds.contents[exclusivity] == true,
            "ContentFacet: Selected Content Scarcity cannot be set"
        };

        ds.contents[contentId].collectionPrice = _collectionPrice; // could be free/0
        ds.contents[contentId].collectionScarcity = _collectionScarcity; // could be infinite

        emit CollectionSetup(ds.contents[creatorId])
    }

    // collecting exclusive content directly from the Mosaic (from Creator)
    function collectContent(
        uint256 contentId,
        uint256 creatorId,
        address buyer,
    ) external {
        require{
            collectionBalance(seller) != 0,
            "ContentFacet: seller doesn't own any collected content"
        };
        require{
            steeloBalance(buyer) < purchasePrice &&
                collectionBalance(buyer) > 0,
            "ContentFacet: buyer cannot purchase the collected content"
        }; 
        require{
            ds.contents[contentId].exclusivity == true,
            "ContentFacet: Content is not exclusive"
        };
        // require that scarcitity is > the quantity of content collected by other users before function is executed 
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        
        emit
    }

    // purchasing content from Bazaar (from Investor)
    function transferCollectionOwnership(
        uint256 contentId,
        address seller,
        address buyer,
        uint256 _purchasePrice,
        uint256 _purchaseTimestamp
    ) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require{
            collectionBalance(seller) != 0,
            "ContentFacet: seller doesn't own any collected content"
        };
        require{
            steeloBalance(buyer) < purchasePrice &&
                collectionBalance(buyer) > 0,
            "ContentFacet: buyer cannot purchase the collected content"
        };

        // transfer ownerOf from seller to buyer

        steeloBalance(seller) + _purchasePrice
        steeloBalance(buyer) - _purchasePrice 

        emit collectionTransferred(conentId, seller, buyer, purchasePrice)
    }
}
