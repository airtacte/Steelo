const express = require('express');
const moderationController = require('../../controllers/common/admin/moderationController');
const router = express.Router();

// Moderate content
router.put('/common/:id/moderate', moderationController.moderateContent);

module.exports = router;