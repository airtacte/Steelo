const express = require('express');
const contentUploadController = require('../../controllers/profile/content/contentUploadController');
const router = express.Router();

// Upload content
router.post('/profile/content', contentUploadController.uploadContent);

module.exports = router;