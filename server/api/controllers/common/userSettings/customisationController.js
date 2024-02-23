const express = require('express');
const UserSettingsService = require('../../../services/UserSettingsService'); // Assuming the path
const router = express.Router();

// Get customisation settings
router.get('/customisation', async (req, res) => {
    try {
        const customisation = await UserSettingsService.getCustomisation();
        res.json(customisation);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;