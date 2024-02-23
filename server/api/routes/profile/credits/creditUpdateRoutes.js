const express = require('express');
const creditUpdateController = require('../../controllers/profile/credits/creditUpdateController');
const router = express.Router();

// Update credits
router.put('/profile/credits', creditUpdateController.updateCredits);

module.exports = router;