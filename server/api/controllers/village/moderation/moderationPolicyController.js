const express = require('express');
const ModerationService = require('../../../services/ModerationService'); // Assuming the path
const router = express.Router();

// Update moderation policy
router.put('/:id/moderationPolicy', async (req, res) => {
    try {
        const policy = await ModerationService.updateModerationPolicy(req.params.id, req.body);
        res.json(policy);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;