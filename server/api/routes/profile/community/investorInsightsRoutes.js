const express = require('express');
const investorInsightsController = require('../../controllers/profile/community/investorInsightsController');
const router = express.Router();

// Get investor insights
router.get('/profile/community/:id/investor-insights', investorInsightsController.getInsights);

module.exports = router;