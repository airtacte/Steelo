const express = require('express');
const HelpService = require('../../../services/HelpService'); // Assuming the path
const router = express.Router();

// Get help resources
router.get('/resources', async (req, res) => {
    try {
        const resources = await HelpService.getHelpResources();
        res.json(resources);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;