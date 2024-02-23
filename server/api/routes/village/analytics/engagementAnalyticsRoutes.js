const express = require('express');
const engagementAnalyticsController = require('../../controllers/village/analytics/engagementAnalyticsController');
const router = express.Router();

// Get engagement analytics
router.get('/village/analytics/engagement', engagementAnalyticsController.getEngagementAnalytics);

module.exports = router;