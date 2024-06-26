// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "../app/AccessControlFacet.sol";
import {ILensHub} from "../../../lib/lens-protocol/contracts/interfaces/ILensHub.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title MosaicFacet
 * A contract to manage content interactions on the Steelo platform,
 * supporting features like collect, follow, like, comment, invest, and credits.
 */
contract MosaicFacet is AccessControlFacet {
    address mosaicFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl;

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    ILensHub public lens;

    // contentId => exclusivity level
    mapping(uint256 => uint8) public contentExclusivity;
    // contentId => array of addresses who have interacted
    mapping(uint256 => address[]) public contentInteractions;

    event ContentCollected(
        address collector,
        uint256 contentId,
        uint256 tokenId
    );
    event Followed(address follower, address followed);
    event Liked(address liker, uint256 contentId);
    event Commented(address commenter, uint256 contentId, string comment);
    event Invested(address investor, address creator, uint256 amount);
    event CreditAssigned(
        uint256 contentId,
        address contributor,
        uint256 proportion
    );
    event ExclusivitySet(uint256 contentId, uint8 exclusivityLevel);

    function initialize(
        address _lens,
        address _steez
    ) external onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        mosaicFacetAddress = ds.mosaicFacetAddress;

        lens = ILensHub(_lens);
    }

    /**
     * @dev Allows a user to collect content as an NFT.
     * This is a simplified representation. The actual function would
     * need to interact with an ERC721 or ERC1155 contract.
     */
    function collectContent(
        uint256 contentId
    ) public onlyRole(accessControl.INVESTOR_ROLE()) {
        require(
            checkExclusivity(contentId, msg.sender),
            "Not eligible to collect this content"
        );
        // Mint NFT or call an external contract to handle NFT creation
        // Placeholder for actual NFT minting logic
        uint256 tokenId = 0; // Suppose an NFT is minted and its ID is obtained here
        emit ContentCollected(msg.sender, contentId, tokenId);
    }

    /**
     * @dev Integrates with the Lens Protocol to follow a user.
     */
    function follow(
        address profileId
    ) public onlyRole(accessControl.USER_ROLE()) {
        // Placeholder for actual follow logic using Lens Protocol
        lens.follow(msg.sender, profileId);
        emit Followed(msg.sender, profileId);
    }

    function like(
        uint256 contentId
    ) external onlyRole(accessControl.USER_ROLE()) {
        // Placeholder: Actual like logic
        emit Liked(msg.sender, contentId);
    }

    function commentOnPublicContent(
        uint256 contentId,
        string calldata comment
    ) external onlyRole(accessControl.USER_ROLE()) {
        // Placeholder: Actual comment logic
        emit Commented(msg.sender, contentId, comment);
    }

    function commentOnExclusiveContent(
        uint256 contentId,
        string calldata comment
    ) external onlyRole(accessControl.INVESTOR_ROLE()) {
        // Placeholder: Actual comment logic
        emit Commented(msg.sender, contentId, comment);
    }

    function invest(
        address creator,
        uint256 amount
    ) external onlyRole(accessControl.USER_ROLE()) {
        // Placeholder: Actual invest logic, possibly involving STEEZ purchase
        emit Invested(msg.sender, creator, amount);
    }

    function assignCredit(
        uint256 contentId,
        address contributor,
        uint256 proportion
    ) external onlyRole(accessControl.CREATOR_ROLE()) {
        // Placeholder: Actual credit assignment logic
        emit CreditAssigned(contentId, contributor, proportion);
    }

    /**
     * @dev Sets the exclusivity level for a piece of content.
     * Can only be called by the content creator or an authorized user.
     */
    function setExclusivity(
        uint256 contentId,
        uint8 exclusivityLevel
    ) public onlyRole(accessControl.CREATOR_ROLE()) {
        contentExclusivity[contentId] = exclusivityLevel;
    }

    function checkExclusivity(
        uint256 contentId,
        address user
    ) public view returns (bool) {
        // Implement checks based on exclusivity level, user's roles, etc.
        return true; // Placeholder: return actual check result
    }
}
