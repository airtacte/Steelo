// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {ConstDiamond} from "../../libraries/ConstDiamond.sol";
import {AccessControlFacet} from "../app/AccessControlFacet.sol";
import {STEEZFacet} from "./STEEZFacet.sol";
import {STEELOFacet} from "../steelo/STEELOFacet.sol";
import {SnapshotFacet} from "../app/SnapshotFacet.sol"; // To setup

contract FeesFacet is AccessControlFacet {
    address feesFacetAddress;
    using LibDiamond for LibDiamond.DiamondStorage;

    AccessControlFacet accessControl;

    constructor(address _accessControlFacetAddress) {
        accessControl = AccessControlFacet(_accessControlFacetAddress);
    }

    event TransferProcessed(
        uint256 indexed steezId,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 royaltyAmount
    );
    event ShareholderUpdated(
        uint256 indexed steezId,
        address indexed shareholder,
        uint256 balance
    );
    event RoyaltiesDistributed(
        address indexed from,
        address indexed to,
        uint256 indexed creatorId,
        uint256 amount,
        uint256 creatorFee,
        uint256 steeloFee,
        uint256 communityFee,
        bytes data
    );
    event FailedPaymentQueued(
        uint256 indexed creatorId,
        address indexed recipient,
        uint256 amount
    );

    function initialize(
        address owner
    ) public onlyRole(accessControl.EXECUTIVE_ROLE()) initializer {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        feesFacetAddress = ds.feesFacetAddress;
    }

    // Called by STEEZFacet.payRoyalties from function transferSteez
    function payRoyalties(
        uint256 creatorId,
        uint256 amount,
        address from,
        address to,
        bytes memory data
    ) external payable onlyRole(accessControl.ADMIN_ROLE()) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 creatorFee = calculateCreatorFee(creatorId, amount);
        uint256 steeloFee = calculateSteeloFee(creatorId, amount);
        uint256 communityFee = calculateCommunityFee(creatorId, amount);

        distributeRoyalties(
            creatorId,
            amount,
            creatorFee,
            steeloFee,
            communityFee,
            from,
            to
        );
        refundExcessPayment(amount);

        bool success = distributeRoyalties(
            creatorId,
            amount,
            creatorFee,
            steeloFee,
            communityFee,
            from,
            to
        );
        if (success) {
            emit RoyaltiesDistributed(
                from,
                to,
                creatorId,
                amount,
                creatorFee,
                steeloFee,
                communityFee,
                data
            );
        } else {
            // Handle failure: log, revert, or queue for retry based on your application's needs
        }
    }

    function calculateCreatorFee(
        uint256 creatorId,
        uint256 amount
    ) internal view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 creatorRate; // 90% of pre-orders, 90% of launch/anniversaries, 5% of second-hand
        uint256 totalSupply = ds.steez[creatorId].totalSupply;

        if (totalSupply > 0 && totalSupply <= ds.constants.PRE_ORDER_SUPPLY) {
            creatorRate = ds.constants.PRE_ORDER_CREATOR_ROYALTY;
        } else if (
            totalSupply > ds.constants.PRE_ORDER_SUPPLY &&
            totalSupply <=
            (ds.constants.PRE_ORDER_SUPPLY + ds.constants.LAUNCH_SUPPLY)
        ) {
            creatorRate = ds.constants.LAUNCH_CREATOR_ROYALTY;
        } else {
            creatorRate = ds.constants.SECOND_HAND_CREATOR_ROYALTY;
        }

        return (amount * creatorRate) / 100;
    }

    function calculateSteeloFee(
        uint256 creatorId,
        uint256 amount
    ) internal view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 steeloRate; // 10% of pre-orders, 7.5% of launch/anniversaries, 2.5% of second-hand
        uint256 totalSupply = ds.steez[creatorId].totalSupply;

        if (totalSupply > 0 && totalSupply <= ds.constants.PRE_ORDER_SUPPLY) {
            steeloRate = ds.constants.PRE_ORDER_STEELO_ROYALTY;
        } else if (
            totalSupply > ds.constants.PRE_ORDER_SUPPLY &&
            totalSupply <=
            (ds.constants.PRE_ORDER_SUPPLY + ds.constants.LAUNCH_SUPPLY)
        ) {
            steeloRate = ds.constants.LAUNCH_STEELO_ROYALTY;
        } else {
            steeloRate = ds.constants.SECOND_HAND_STEELO_ROYALTY;
        }

        return (amount * steeloRate) / 100;
    }

    function calculateCommunityFee(
        uint256 creatorId,
        uint256 amount
    ) internal view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 communityRate; // 0% of pre-orders, 2.5% of launch/anniversaries, 2.5% of second-hand
        uint256 totalSupply = ds.steez[creatorId].totalSupply;

        // Assuming the community rate is the same for launch and anniversary
        if (totalSupply > 0 && totalSupply <= ds.constants.PRE_ORDER_SUPPLY) {
            communityRate = 0; // Assuming no community fee for pre-order
        } else if (totalSupply > ds.constants.PRE_ORDER_SUPPLY) {
            communityRate = ds.constants.LAUNCH_COMMUNITY_ROYALTY;
        } else {
            communityRate = ds.constants.SECOND_HAND_COMMUNITY_ROYALTY;
        }

        return (amount * communityRate) / 100;
    }

    function distributeRoyalties(
        uint256 creatorId,
        uint256 amount,
        address from,
        address to
    ) internal nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // Calculate fees based on predefined rates in LibDiamond and ConstDiamond
        uint256 creatorFee = calculateCreatorFee(creatorId, amount);
        uint256 steeloFee = calculateSteeloFee(creatorId, amount);
        uint256 communityFee = calculateCommunityFee(creatorId, amount);

        bool success;
        // Pay the creator their royalty
        (success, ) = payable(ds.creators[creatorId].profileAddress).call{
            value: creatorFee
        }("");
        require(success, "Royalties: Creator fee transfer failed");

        // Pay the platform its royalty
        (success, ) = payable(ds.constants.steeloAddress).call{
            value: steeloFee
        }("");
        require(success, "Royalties: Steelo fee transfer failed");

        // Distribute the community fee
        distributeCommunityFee(creatorId, communityFee);

        emit RoyaltiesDistributed(
            from,
            to,
            creatorId,
            amount,
            creatorFee,
            steeloFee,
            communityFee,
            ""
        );
    }

    function distributeCommunityFee(
        uint256 creatorId,
        uint256 communityFee
    ) internal nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 totalSupply = ds.steez[creatorId].totalSupply;
        // Iterate through each investor to distribute community fees proportionally
        for (uint256 i = 0; i < ds.steez[creatorId].investors.length; i++) {
            address payable investorAddress = payable(
                ds.steez[creatorId].investors[i].investorAddress
            );
            uint256 investorBalance = ds.steez[creatorId].investors[i].balance;
            uint256 investorShare = (communityFee * investorBalance) /
                totalSupply;

            // Attempt to transfer the investor's share of the community fee
            (bool success, ) = investorAddress.call{value: investorShare}("");
            if (!success) {
                // If transfer fails, queue the failed payment for retry
                queueFailedRoyaltyPayment(
                    creatorId,
                    investorShare,
                    investorAddress
                );
            }
            // Consider implementing a more gas-efficient event strategy here
        }
    }

    function queueFailedRoyaltyPayment(
        uint256 creatorId,
        uint256 amount,
        address payable recipient
    ) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // Add the failed payment to the queue
        ds.failedPayments[creatorId].push(ds.FailedPayment(amount, recipient));

        // Emit an event for transparency
        emit FailedPaymentQueued(creatorId, recipient, amount);
    }

    function refundExcessPayment(uint256 paymentAmount) internal nonReentrant {
        uint256 excessPayment = msg.value - paymentAmount;
        if (excessPayment > 0) {
            (bool success, ) = payable(msg.sender).call{value: excessPayment}(
                ""
            );
            require(success, "Royalties: Refund failed");
        }
    }

    function viewRoyalties(
        address user,
        uint256 creatorId
    ) public view returns (uint256 userShare, uint256 userRoyalty) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        if (
            ds.steez[creatorId].totalSupply == 0 ||
            ds.steez[creatorId].balance == 0
        ) {
            return (0, 0);
        }

        // Calculate user's share of the royalty
        userShare =
            (ds.royalty.totalRoyalties * ds.steez[creatorId].balance) /
            ds.steez[creatorId].totalSupply;

        // Calculate user's total royalty
        uint256 userSharePercentage = (ds.steez[creatorId].balance * 10000) /
            ds.steez[creatorId].totalSupply;
        userRoyalty =
            (ds.royalty.royaltyAmounts[user] * userSharePercentage) /
            10000;

        if (user == ds.steez[creatorId].creator) {
            userRoyalty = userRoyalty + ds.royalty.creatorRoyalty;
        } else if (user == ds.steezFacetAddress) {
            // Assuming ds.steezFacetAddress is the address of steelo
            userRoyalty = userRoyalty + ds.royalty.steeloRoyalty;
        } else if (ds.royalty.royaltyAmounts[user] > 0) {
            // Assuming the user is an investor if they have any royalty amounts
            userRoyalty = userRoyalty + ds.royalty.investorRoyalty;
        } else {
            userRoyalty = 0; // If the user is not related to the STEEZ, their royalty is 0
        }

        userRoyalty = userRoyalty + ds.royalty.unclaimedRoyalties;

        return (userShare, userRoyalty);
    }

    // New Function to Add to Queue (Example)
    function queueRoyaltyPayment(
        uint256 _creatorId,
        uint256 _amount,
        address payable _recipient
    ) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_amount > 0, "Royalties: Amount must be greater than zero");
        require(isValidParticipant(_recipient), "Royalties: Invalid recipient");
        ds.royaltyQueue.push(
            ds.QueuedRoyalty({
                creatorId: _creatorId,
                amount: _amount,
                recipient: _recipient
            })
        );
    }

    function processRoyaltyQueue() public onlyRole(accessControl.ADMIN_ROLE()) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(
            ds.royaltyQueue.length > 0,
            "Royalties: No royalties to process"
        );
        uint256 totalRoyaltiesProcessed = 0;

        for (uint i = 0; i < ds.royaltyQueue.length; i++) {
            LibDiamond.QueuedRoyalty memory queuedPayment = ds.royaltyQueue[i];
            require(queuedPayment.amount > 0, "Royalties: Invalid amount");
            require(
                isValidParticipant(queuedPayment.recipient),
                "Royalties: Invalid recipient"
            );

            queuedPayment.recipient.transfer(queuedPayment.amount);
            totalRoyaltiesProcessed += queuedPayment.amount;

            emit RoyaltiesDistributed(
                queuedPayment.from,
                queuedPayment.to,
                queuedPayment.creatorId,
                queuedPayment.amount,
                queuedPayment.creatorFee,
                queuedPayment.steeloFee,
                queuedPayment.communityFee,
                queuedPayment.data
            );
        }

        delete ds.royaltyQueue;
        // Log the total royalties processed in this batch
    }

    // New helper function for validating participants
    function isValidParticipant(
        address participant
    ) private view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // Placeholder for validation logic
        return true;
    }

    // Assuming the use of an external keeper or automated job for triggering
    // This would be set up outside of the Solidity contract, utilizing a service like Chainlink Keepers
    // to call `processRoyaltyQueue()` based on predefined conditions such as time intervals or queue size.
    // The processRoyaltyQueue function above inherently uses the batch processing capabilities of zkEVM
    // by aggregating multiple transactions. Further optimization can be explored based on zkEVM's specific features
}
