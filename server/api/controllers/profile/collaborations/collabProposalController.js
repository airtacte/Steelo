const express = require('express');
const CollabProposalService = require('../../../services/CollabProposalService'); // Assuming the path
const router = express.Router();

// Propose a collaboration
router.post('/', async (req, res) => {
    try {
        const proposal = await CollabProposalService.proposeCollab(req.body);
        res.status(201).json(proposal);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;