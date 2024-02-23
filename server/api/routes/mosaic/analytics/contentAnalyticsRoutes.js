const express = require('express');
const router = express.Router();
const { getContentAnalytics } = require('../../controllers/mosaic/analytics/contentAnalyticsController');

router.get('/:contentId', getContentAnalytics);

module.exports = router;