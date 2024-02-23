const express = require('express');
const router = express.Router();
const contentUploadController = require('../../controllers/mosaic/management/contentUploadController');

router.post('/upload', contentUploadController.uploadContent);

module.exports = router;