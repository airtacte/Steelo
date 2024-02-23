const express = require('express');
const GovernanceService = require('../../../services/GovernanceService'); // Assuming the path
const router = express.Router();

// Get governance analytics
router.get('/analytics', async (req, res) => {
    try {
        const analytics = await GovernanceService.getGovernanceAnalytics();
        res.json(analytics);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;