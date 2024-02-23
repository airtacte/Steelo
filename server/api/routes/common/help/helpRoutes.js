const express = require('express');
const helpController = require('../../controllers/common/help/helpController');
const router = express.Router();

// Get help resources
router.get('/common/help/resources', helpController.getHelpResources);

module.exports = router;