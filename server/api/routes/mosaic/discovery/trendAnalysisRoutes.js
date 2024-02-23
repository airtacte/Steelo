const express = require('express');
const router = express.Router();
const trendAnalysisController = require('../../controllers/mosaic/discovery/trendAnalysisController');

router.get('/trends', trendAnalysisController.analyzeTrends);

module.exports = router;