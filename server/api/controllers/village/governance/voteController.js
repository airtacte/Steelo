const express = require('express');
const GovernanceService = require('../../../services/GovernanceService'); // Assuming the path
const router = express.Router();

// Cast vote
router.post('/:id/vote', async (req, res) => {
    try {
        const vote = await GovernanceService.castVote(req.params.id, req.body);
        res.status(201).json(vote);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;