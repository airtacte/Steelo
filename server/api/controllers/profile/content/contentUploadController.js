const express = require('express');
const ContentUploadService = require('../../../services/ContentUploadService'); // Assuming the path
const router = express.Router();

// Upload content
router.post('/', async (req, res) => {
  try {
    const contentMetadata = await ContentUploadService.uploadContent(req.file, req.body);
    res.status(201).json(contentMetadata);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

module.exports = router;