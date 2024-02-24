const express = require('express');
const router = express.Router();
const searchController = require('../../controllers/bazaar/userExperience/SearchController');

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

router.get('/', authorize, searchController.performSearch);

module.exports = router;