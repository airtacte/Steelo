const express = require('express');
const portfolioInsightsController = require('../../controllers/profile/portfolio/portfolioInsightsController');
const router = express.Router();

// Get portfolio insights
router.get('/profile/portfolio/:id/insights', portfolioInsightsController.getInsights);

module.exports = router;