const express = require('express');
const creditDisplayController = require('../../controllers/profile/credits/creditDisplayController');
const router = express.Router();

// Display credits
router.get('/profile/credits', creditDisplayController.getCredits);

module.exports = router;