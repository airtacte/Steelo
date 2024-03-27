const express = require('express');
const router = express.Router();
const { getInteractionAnalytics } = require('../../controllers/mosaic/analytics/InteractionAnalyticsController');

router.get('/interactions/:contentId', getInteractionAnalytics);

module.exports = router;