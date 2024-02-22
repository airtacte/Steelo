const express = require('express');
const analyticsDataController = require('../../controllers/gallery/analytics/analyticsDataController');
const router = express.Router();

router.get('/data', analyticsDataController.getAnalyticsData);

module.exports = router;