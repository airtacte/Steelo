const express = require('express');
const contentControlController = require('../../controllers/common/admin/contentControlController');
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

// Control content
router.put('/common/:id/contentControl', authorize, validateInput, contentControlController.controlContent);

module.exports = router;