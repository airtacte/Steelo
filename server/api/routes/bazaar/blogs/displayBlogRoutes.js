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

// Route to display a specific blog post by ID
router.get('/display/:id', authorize, blogController.displayBlog);

module.exports = router;