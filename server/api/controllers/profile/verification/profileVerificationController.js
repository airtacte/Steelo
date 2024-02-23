const express = require('express');
const ProfileService = require('../../../services/ProfileService'); // Assuming the path
const router = express.Router();

// Verify profile
router.put('/:id/verify', async (req, res) => {
    try {
        const profile = await ProfileService.verifyProfile(req.params.id);
        res.json(profile);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;