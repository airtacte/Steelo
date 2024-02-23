const express = require('express');
const contentDeletionController = require('../../controllers/profile/content/contentDeletionController');
const router = express.Router();

// Delete content
router.delete('/profile/content/:id', contentDeletionController.deleteContent);

module.exports = router;