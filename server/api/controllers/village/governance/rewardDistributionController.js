const express = require('express');
const GovernanceService = require('../../../services/GovernanceService'); // Assuming the path
const router = express.Router();

// Distribute rewards
router.post('/:id/rewards', async (req, res) => {
    try {
        const rewards = await GovernanceService.distributeRewards(req.params.id, req.body);
        res.status(201).json(rewards);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;