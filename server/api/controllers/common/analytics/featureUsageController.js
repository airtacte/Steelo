const express = require('express');
const AnalyticsService = require('../../../services/AnalyticsService'); // Assuming the path
const router = express.Router();

// Get feature usage data
router.get('/:id/featureUsage', async (req, res) => {
    try {
        const usage = await AnalyticsService.getFeatureUsageData(req.params.id);
        res.json(usage);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;