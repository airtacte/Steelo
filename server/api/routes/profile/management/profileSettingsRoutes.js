const express = require('express');
const profileSettingsController = require('../../controllers/profile/management/profileSettingsController');
const router = express.Router();

// Update profile settings
router.put('/profile/settings/:id', profileSettingsController.updateSettings);

module.exports = router;