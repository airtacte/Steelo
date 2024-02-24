const express = require('express');
const AnalyticsService = require('../../../services/AnalyticsService'); // Assuming the path
const { query, validationResult } = require('express-validator');
const router = express.Router();

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};

// Generate admin report
router.get('/:id/adminReport', [
    authorize,
    query('type').isIn(['marketDynamics', 'tokenPerformance', 'userEngagement', 'auctionDynamics', 'rewardSystemInsights', 'stakingAnalytics', 'sentimentAndTrends', 'customizationAndPreferences']).withMessage('Invalid report type'),
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const report = await AnalyticsService.generateAdminReport(req.params.id, req.query.type);
            res.json(report);
        } catch (error) {
            res.status(500).send(error.message);
        }
    }
]);

module.exports = router;