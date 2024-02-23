const express = require('express');
const commonController = require('../../controllers/common/utils/commonController');
const router = express.Router();

// Get common utilities
router.get('/common/utils/common', commonController.getCommonUtils);

module.exports = router;