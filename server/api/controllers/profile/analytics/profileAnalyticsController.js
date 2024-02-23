const express = require('express');
const ProfileAnalyticsService = require('../../../services/ProfileAnalyticsService'); // Assuming the path
const router = express.Router();

// Get profile analytics
router.get('/:id', async (req, res) => {
    try {
        const analytics = await ProfileAnalyticsService.getAnalytics(req.params.id);
        res.json(analytics);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Update profile analytics
router.put('/:id', async (req, res) => {
    try {
        const updatedAnalytics = await ProfileAnalyticsService.updateAnalytics(req.params.id, req.body);
        res.json(updatedAnalytics);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;