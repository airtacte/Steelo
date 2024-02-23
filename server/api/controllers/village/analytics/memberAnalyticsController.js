const express = require('express');
const AnalyticsService = require('../../../services/AnalyticsService'); // Assuming the path
const router = express.Router();

// Get member analytics
router.get('/members', async (req, res) => {
    try {
        const analytics = await AnalyticsService.getMemberAnalytics();
        res.json(analytics);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;