const express = require('express');
const adminReportController = require('../../controllers/common/analytics/adminReportController');
const router = express.Router();

// Generate admin report
router.get('/common/:id/adminReport', adminReportController.generateAdminReport);

module.exports = router;