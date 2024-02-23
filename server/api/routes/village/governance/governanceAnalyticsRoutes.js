const express = require('express');
const governanceAnalyticsController = require('../../controllers/village/governance/governanceAnalyticsController');
const router = express.Router();

// Get governance analytics
router.get('/village/governance/analytics', governanceAnalyticsController.getGovernanceAnalytics);

module.exports = router;