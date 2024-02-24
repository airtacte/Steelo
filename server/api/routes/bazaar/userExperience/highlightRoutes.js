const express = require('express');
const router = express.Router();
const highlightController = require('../../controllers/bazaar/userExperience/highlightController');

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

router.get('/', authorize, highlightController.getHighlights);
router.post('/', authorize, validateInput, highlightController.addHighlight);

module.exports = router;