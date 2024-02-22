const express = require('express');
const router = express.Router();
const rewardCalculationController = require('../../controllers/gallery/stakingRewards/rewardCalculationController');

router.post('/calculate', rewardCalculationController.calculateRewards);

module.exports = router;