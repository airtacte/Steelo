//Ensure that profilePersonalisationController.js covers all aspects of user personalization beyond visual elements, like notification settings or content preferences.

const express = require('express');
const ProfileService = require('../../../services/ProfileService'); // Assuming the path
const router = express.Router();

// Personalise profile
router.put('/:id', async (req, res) => {
    try {
        const profile = await ProfileService.personaliseProfile(req.params.id, req.body);
        res.json(profile);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;