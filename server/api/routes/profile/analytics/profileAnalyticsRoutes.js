const express = require('express');
const profileAnalyticsController = require('../../controllers/profile/analytics/profileAnalyticsController');
const router = express.Router();

// Get profile analytics
router.get('/profile/:id/analytics', profileAnalyticsController.getAnalytics);

// Update profile analytics
router.put('/profile/:id/analytics', profileAnalyticsController.updateAnalytics);

module.exports = router;