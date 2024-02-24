const express = require('express');
const router = express.Router();
const recommendationController = require('../../controllers/bazaar/userExperience/recommendationController');

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

router.get('/:userId', authorize, recommendationController.getRecommendations);

module.exports = router;