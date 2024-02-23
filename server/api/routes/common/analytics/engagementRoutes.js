const express = require('express');
const engagementController = require('../../controllers/common/analytics/engagementController');
const router = express.Router();

// Get engagement data
router.get('/common/:id/engagement', engagementController.getEngagementData);

module.exports = router;