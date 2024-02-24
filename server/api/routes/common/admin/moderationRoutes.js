const express = require('express');
const moderationController = require('../../controllers/common/admin/moderationController');
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

// Moderate content
router.put('/common/:id/moderate', authorize, validateInput, moderationController.moderateContent);

module.exports = router;