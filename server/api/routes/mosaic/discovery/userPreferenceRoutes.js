const express = require('express');
const router = express.Router();
const userPreferenceController = require('../../controllers/mosaic/discovery/userPreferenceController');

router.put('/preferences', userPreferenceController.updateUserPreferences);

module.exports = router;