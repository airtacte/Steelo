const express = require('express');
const collabProposalController = require('../../controllers/profile/collaborations/collabProposalController');
const router = express.Router();

// Propose a collaboration
router.post('/profile/collaborations/proposal', collabProposalController.proposeCollab);

module.exports = router;