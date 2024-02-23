const express = require('express');
const portfolioDisplayController = require('../../controllers/profile/portfolio/portfolioDisplayController');
const router = express.Router();

// Display portfolio
router.get('/profile/portfolio/:id', portfolioDisplayController.getPortfolio);

module.exports = router;