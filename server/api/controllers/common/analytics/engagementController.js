const express = require('express');
const AnalyticsService = require('../../../services/AnalyticsService'); // Assuming the path
const router = express.Router();

// Get engagement data
router.get('/:id/engagement', async (req, res) => {
    try {
        const engagement = await AnalyticsService.getEngagementData(req.params.id);
        res.json(engagement);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;