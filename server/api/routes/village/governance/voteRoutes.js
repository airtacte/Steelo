const express = require('express');
const voteController = require('../../controllers/village/governance/voteController');
const router = express.Router();

// Cast vote
router.post('/village/governance/:id/vote', voteController.castVote);

module.exports = router;