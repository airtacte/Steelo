const express = require('express');
const performanceReportController = require('../../controllers/gallery/analytics/performanceReportController');
const router = express.Router();

router.get('/report', performanceReportController.getPerformanceReport);

module.exports = router;