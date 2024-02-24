const express = require('express');
const router = express.Router();
const blogController = require('../../controllers/blogController');

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

// Route for processing payments to read a premium blog post
// Assuming this might require additional parameters or a body with payment details
router.post('/payToRead/:id', authorize, validateInput, blogController.payMeToRead);

module.exports = router;