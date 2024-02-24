const express = require('express');
const searchController = require('../../controllers/common/utils/searchController');
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
  
// Get search results
router.get('/common/utils/search', authorize, searchController.getSearchResults);

module.exports = router;