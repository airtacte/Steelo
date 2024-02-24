const express = require('express');
const AnalyticsService = require('../../../services/AnalyticsService'); // Assuming the path
const { validationResult, param } = require('express-validator');
const router = express.Router();

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user) {
        return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};

// Get feature usage data
router.get('/:id/featureUsage', [
    authorize,
    param('id').isString().withMessage('Invalid id'),
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const usage = await AnalyticsService.getFeatureUsageData(req.params.id);
            res.json(usage);
        } catch (error) {
            res.status(500).send(error.message);
        }
    }
]);

module.exports = router;