const express = require('express');
const preferencesController = require('../../controllers/common/userSettings/preferencesController');
const router = express.Router();

// Get preferences
router.get('/common/userSettings/preferences', preferencesController.getPreferences);

module.exports = router;