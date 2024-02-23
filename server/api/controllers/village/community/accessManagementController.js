const express = require('express');
const CommunityService = require('../../../services/CommunityService'); // Assuming the path
const router = express.Router();

// Manage access
router.put('/:id/access', async (req, res) => {
    try {
        const community = await CommunityService.manageAccess(req.params.id, req.body);
        res.json(community);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;