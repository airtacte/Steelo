const express = require('express');
const router = express.Router();
const { updatePreferences } = require('../../controllers/gallery/engagement/userPreferencesController');

router.put('/preferences', updatePreferences);

module.exports = router;