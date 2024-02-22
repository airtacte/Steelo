const express = require('express');
const router = express.Router();
const blogController = require('../../controllers/blogController');

// Route for uploading a new blog post
// This should include middleware for authentication to ensure only authorized users can upload
router.post('/upload', blogController.uploadBlog);

module.exports = router;