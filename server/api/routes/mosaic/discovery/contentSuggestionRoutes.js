const express = require('express');
const router = express.Router();
const contentSuggestionController = require('../../controllers/mosaic/discovery/contentSuggestionController');

router.get('/suggestions', contentSuggestionController.getContentSuggestions);

module.exports = router;