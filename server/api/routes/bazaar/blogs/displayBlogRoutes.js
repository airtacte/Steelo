const express = require('express');
const router = express.Router();
const blogController = require('../../controllers/blogController');

// Route to display a specific blog post by ID
router.get('/display/:id', blogController.displayBlog);

module.exports = router;