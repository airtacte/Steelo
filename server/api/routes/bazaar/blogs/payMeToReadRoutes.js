const express = require('express');
const router = express.Router();
const blogController = require('../../controllers/blogController');

// Route for processing payments to read a premium blog post
// Assuming this might require additional parameters or a body with payment details
router.post('/payToRead/:id', blogController.payMeToRead);

module.exports = router;