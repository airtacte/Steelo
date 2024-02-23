const express = require('express');
const creditEarningController = require('../../controllers/profile/credits/creditEarningController');
const router = express.Router();

// Earn credits
router.post('/profile/credits/earn', creditEarningController.earnCredits);

module.exports = router;creditEarningController