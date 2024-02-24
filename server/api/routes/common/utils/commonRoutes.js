const express = require('express');
const commonController = require('../../controllers/common/utils/commonController');
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

  
// Get common utilities
router.get('/common/utils/common', authorize, commonController.getCommonUtils);

module.exports = router;