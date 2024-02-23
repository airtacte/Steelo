const express = require('express');
const AnalyticsService = require('../../../services/AnalyticsService'); // Assuming the path
const router = express.Router();

// Generate admin report
router.get('/:id/adminReport', async (req, res) => {
    try {
        const report = await AnalyticsService.generateAdminReport(req.params.id);
        res.json(report);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;