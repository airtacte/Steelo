const express = require('express');
const adminReportController = require('../../controllers/common/analytics/adminReportController');
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

// Generate admin report
router.get('/common/:id/adminReport', authorize, validateInput, adminReportController.generateAdminReport);

module.exports = router;