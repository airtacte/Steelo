const express = require('express');
const searchController = require('../../controllers/common/utils/searchController');
const router = express.Router();

// Get search results
router.get('/common/utils/search', searchController.getSearchResults);

module.exports = router;