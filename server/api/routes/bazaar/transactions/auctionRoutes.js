const AuctionsService = require('../services/auctionsService');
const express = require('express');
const { startAuction, placeBid, endAuction } = require('../../controllers/bazaar/transactions/auctionController');
const router = express.Router();

// Auction Management
router.post('/initiateAuction', protect, initiateAuction);
router.post('/placeBid', protect, placeBid);
router.get('/fetchLeaderboard', protect, fetchLeaderboard);

exports.startAuction = async (req, res) => {
    try {
        const auction = await AuctionsService.startNewAuction(req.body);
        res.status(201).json(auction);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.placeBid = async (req, res) => {
    try {
        const auction = await AuctionsService.placeBid(req.params.auctionId, req.body);
        res.json(auction);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

router.post('/end', endAuction);

module.exports = router;