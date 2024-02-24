const express = require('express');
const analyticsController = require('../../controllers/bazaar/analyticsController');
const router = express.Router();

// Route to get analytics data for a specific asset
router.get('/analytics/:assetId', analyticsController.getAssetAnalytics);

module.exports = router;