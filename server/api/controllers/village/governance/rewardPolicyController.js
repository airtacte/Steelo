const express = require('express');
const GovernanceService = require('../../../services/GovernanceService'); // Assuming the path
const router = express.Router();

// Update reward policy
router.put('/:id/rewardPolicy', async (req, res) => {
    try {
        const policy = await GovernanceService.updateRewardPolicy(req.params.id, req.body);
        res.json(policy);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;