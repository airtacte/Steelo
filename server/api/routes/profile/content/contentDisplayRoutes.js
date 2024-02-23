const express = require('express');
const contentDisplayController = require('../../controllers/profile/content/contentDisplayController');
const router = express.Router();

// Display content
router.get('/profile/content/:id', contentDisplayController.getContent);

module.exports = router;