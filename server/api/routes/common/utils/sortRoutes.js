const express = require('express');
const sortController = require('../../controllers/common/utils/sortController');
const router = express.Router();

// Get sorted results
router.get('/common/utils/sort', sortController.getSortedResults);

module.exports = router;