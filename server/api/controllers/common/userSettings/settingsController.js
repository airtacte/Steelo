const express = require('express');
const UserSettingsService = require('../../../services/UserSettingsService'); // Assuming the path
const router = express.Router();

// Get settings
router.get('/settings', async (req, res) => {
    try {
        const settings = await UserSettingsService.getSettings();
        res.json(settings);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;