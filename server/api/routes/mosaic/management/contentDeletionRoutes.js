const express = require('express');
const router = express.Router();
const contentDeletionController = require('../../controllers/mosaic/management/contentDeletionController');

router.delete('/delete/:contentId', contentDeletionController.deleteContent);

module.exports = router;