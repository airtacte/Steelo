const express = require('express');
const proposalController = require('../../controllers/village/governance/proposalController');
const router = express.Router();

// Create proposal
router.post('/village/governance/:id/proposal', proposalController.createProposal);

module.exports = router;