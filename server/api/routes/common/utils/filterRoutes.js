const express = require('express');
const filterController = require('../../controllers/common/utils/filterController');
const router = express.Router();

// Get filters
router.get('/common/utils/filters', filterController.getFilters);

module.exports = router;