const express = require('express');
const rewardPolicyController = require('../../controllers/village/governance/rewardPolicyController');
const router = express.Router();

// Update reward policy
router.put('/village/governance/:id/rewardPolicy', rewardPolicyController.updateRewardPolicy);

module.exports = router;