const express = require('express');
const featureUsageController = require('../../controllers/common/analytics/featureUsageController');
const router = express.Router();

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user) {
      return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};
  
  // Middleware for input validation
  const validateInput = (req, res, next) => {
    // Add your input validation logic here
    next();
};


// Get feature usage data
router.get('/common/:id/featureUsage', authorize, featureUsageController.getFeatureUsageData);

module.exports = router;