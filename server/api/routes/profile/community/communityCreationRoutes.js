const express = require('express');
const communityCreationController = require('../../controllers/profile/community/communityCreationController');
const router = express.Router();

// Create a community
router.post('/profile/community', communityCreationController.createCommunity);

module.exports = router;