const express = require('express');
const moderationPolicyController = require('../../controllers/village/moderation/moderationPolicyController');
const router = express.Router();

// Update moderation policy
router.put('/village/:id/moderationPolicy', moderationPolicyController.updateModerationPolicy);

module.exports = router;