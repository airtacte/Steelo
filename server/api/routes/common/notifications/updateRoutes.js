const express = require('express');
const updateController = require('../../controllers/common/notifications/updateController');
const router = express.Router();

// Get updates
router.get('/common/notifications/updates', updateController.getUpdates);

module.exports = router;