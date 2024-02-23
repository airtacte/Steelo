const express = require('express');
const CommunityManagementService = require('../../../services/CommunityManagementService'); // Assuming the path
const router = express.Router();

// Update a community
router.put('/:id', async (req, res) => {
    try {
        const updatedCommunity = await CommunityManagementService.updateCommunity(req.params.id, req.body);
        res.json(updatedCommunity);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Delete a community
router.delete('/:id', async (req, res) => {
    try {
        await CommunityManagementService.deleteCommunity(req.params.id);
        res.status(204).send();
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;