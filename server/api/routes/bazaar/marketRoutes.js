const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  addLiquidity,
  createPool,
  swapTokens,
  initiateAuction,
  placeBid,
  fetchLeaderboard,
  stakeTokens,
  calculateYield,
  distributeRewards,
} = require('../controllers/bazaarController');

const router = express.Router();

// Liquidity Management
router.post('/createPool', protect, createPool);
router.post('/addLiquidity', protect, addLiquidity);

// Token Trading
router.post('/swapTokens', protect, swapTokens);

// Auction Management
router.post('/initiateAuction', protect, initiateAuction);
router.post('/placeBid', protect, placeBid);
router.get('/fetchLeaderboard', protect, fetchLeaderboard);

// Staking and Rewards
router.post('/stakeTokens', protect, stakeTokens);
router.get('/calculateYield', protect, calculateYield);
router.post('/distributeRewards', protect, distributeRewards);

module.exports = router;