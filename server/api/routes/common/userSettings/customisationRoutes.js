const express = require('express');
const customisationController = require('../../controllers/common/userSettings/customisationController');
const router = express.Router();

// Get customisation settings
router.get('/common/userSettings/customisation', customisationController.getCustomisation);

module.exports = router;