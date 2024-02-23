const express = require('express');
const contentModerationController = require('../../controllers/village/moderation/contentModerationController');
const router = express.Router();

// Moderate content
router.put('/village/:id/moderate', contentModerationController.moderateContent);

module.exports = router;