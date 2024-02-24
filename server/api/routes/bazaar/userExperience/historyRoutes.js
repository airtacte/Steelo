const express = require('express');
const router = express.Router();
const historyController = require('../../controllers/bazaar/userExperience/historyController');

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

router.get('/:userId', authorize, validateInput, historyController.getUserHistory);
router.delete('/:userId', authorize, historyController.clearHistory);

module.exports = router;