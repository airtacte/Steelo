const express = require('express');
const featureUsageController = require('../../controllers/common/analytics/featureUsageController');
const router = express.Router();

// Get feature usage data
router.get('/common/:id/featureUsage', featureUsageController.getFeatureUsageData);

module.exports = router;