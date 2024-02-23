const express = require('express');
const CommunityCreationService = require('../../../services/CommunityCreationService'); // Assuming the path
const router = express.Router();

// Create a community
router.post('/', async (req, res) => {
    try {
        const community = await CommunityCreationService.createCommunity(req.body);
        res.status(201).json(community);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;