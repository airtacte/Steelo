const express = require('express');
const GovernanceService = require('../../../services/GovernanceService'); // Assuming the path
const router = express.Router();

// Create proposal
router.post('/:id/proposal', async (req, res) => {
    try {
        const proposal = await GovernanceService.createProposal(req.params.id, req.body);
        res.status(201).json(proposal);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;