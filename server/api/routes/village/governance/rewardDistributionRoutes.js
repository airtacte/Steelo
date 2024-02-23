const express = require('express');
const rewardDistributionController = require('../../controllers/village/governance/rewardDistributionController');
const router = express.Router();

// Distribute rewards
router.post('/village/governance/:id/rewards', rewardDistributionController.distributeRewards);

module.exports = router;