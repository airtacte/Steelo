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

// Route for uploading a new blog post
// This should include middleware for authentication to ensure only authorized users can upload
router.post('/upload', authorize, validateInput, blogController.uploadBlog);

module.exports = router;