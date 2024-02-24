const express = require('express');
const { initiateAuction, placeBid, autoBidToggle, fetchLeaderboard, endAuction } = require('../../controllers/bazaar/transactions/auctionController');
const router = express.Router();

// Auction Management
router.post('/initiateAuction', protect, initiateAuction);
router.post('/placeBid', protect, placeBid);
router.post('/autoBidToggle', protect, autoBidToggle);
router.get('/fetchLeaderboard', protect, fetchLeaderboard);
router.post('/endAuction', protect, endAuction);

module.exports = router;