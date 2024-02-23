const express = require('express');
const settingsController = require('../../controllers/common/userSettings/settingsController');
const router = express.Router();

// Get settings
router.get('/common/userSettings/settings', settingsController.getSettings);

module.exports = router;