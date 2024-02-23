const express = require('express');
const AnalyticsService = require('../../../services/AnalyticsService'); // Assuming the path
const router = express.Router();

// Get engagement analytics
router.get('/engagement', async (req, res) => {
    try {
        const analytics = await AnalyticsService.getEngagementAnalytics();
        res.json(analytics);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;