const express = require('express');
const router = express.Router();
const stakeRewardsController = require('../../controllers/gallery/stakingRewards/stakeRewardsController');

router.post('/distribute', stakeRewardsController.distributeRewards);

module.exports = router;