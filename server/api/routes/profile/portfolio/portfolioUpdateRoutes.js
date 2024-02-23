const express = require('express');
const portfolioUpdateController = require('../../controllers/profile/portfolio/portfolioUpdateController');
const router = express.Router();

// Update portfolio
router.put('/profile/portfolio/:id', portfolioUpdateController.updatePortfolio);

module.exports = router;