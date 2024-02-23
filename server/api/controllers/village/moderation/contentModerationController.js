const express = require('express');
const ModerationService = require('../../../services/ModerationService'); // Assuming the path
const router = express.Router();

// Moderate content
router.put('/:id/moderate', async (req, res) => {
    try {
        const moderation = await ModerationService.moderateContent(req.params.id, req.body);
        res.json(moderation);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;