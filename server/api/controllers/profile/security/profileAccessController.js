const express = require('express');
const ProfileService = require('../../../services/ProfileService'); // Assuming the path
const router = express.Router();

// Update profile access
router.put('/:id/access', async (req, res) => {
    try {
        const profile = await ProfileService.updateAccess(req.params.id, req.body);
        res.json(profile);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;