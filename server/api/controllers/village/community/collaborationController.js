const express = require('express');
const CommunityService = require('../../../services/CommunityService'); // Assuming the path
const router = express.Router();

// Collaborate
router.post('/:id/collaborate', async (req, res) => {
    try {
        const collaboration = await CommunityService.collaborate(req.params.id, req.body);
        res.json(collaboration);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;