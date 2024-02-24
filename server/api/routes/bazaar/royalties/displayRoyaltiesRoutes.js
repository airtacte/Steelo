const express = require('express');
const router = express.Router();
const { displayRoyalties } = require('../../controllers/bazaar/royalties/displayRoyaltiesController');

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

// Route for displaying royalties for a specific creator
router.get('/:creatorId', authorize, displayRoyalties);

module.exports = router;