const express = require('express');
const engagementController = require('../../controllers/common/analytics/engagementController');
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

// Get engagement data
router.get('/common/:id/engagement', authorize, engagementController.getEngagementData);

module.exports = router;