const express = require('express');
const ProfileService = require('../../../services/ProfileService'); // Assuming the path
const router = express.Router();

// Update profile settings
router.put('/:id', async (req, res) => {
    try {
        const profile = await ProfileService.updateSettings(req.params.id, req.body);
        res.json(profile);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;