const express = require('express');
const memberAnalyticsController = require('../../controllers/village/analytics/memberAnalyticsController');
const router = express.Router();

// Get member analytics
router.get('/village/analytics/members', memberAnalyticsController.getMemberAnalytics);

module.exports = router;