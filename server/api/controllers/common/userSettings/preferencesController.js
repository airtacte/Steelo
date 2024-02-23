const express = require('express');
const UserSettingsService = require('../../../services/UserSettingsService'); // Assuming the path
const router = express.Router();

// Get preferences
router.get('/preferences', async (req, res) => {
    try {
        const preferences = await UserSettingsService.getPreferences();
        res.json(preferences);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;