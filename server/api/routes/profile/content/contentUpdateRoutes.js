const express = require('express');
const contentUpdateController = require('../../controllers/profile/content/contentUpdateController');
const router = express.Router();

// Update content
router.put('/profile/content/:id', contentUpdateController.updateContent);

module.exports = router;