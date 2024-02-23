const express = require('express');
const communityManagementController = require('../../controllers/profile/community/communityManagementController');
const router = express.Router();

// Update a community
router.put('/profile/community/:id', communityManagementController.updateCommunity);

// Delete a community
router.delete('/profile/community/:id', communityManagementController.deleteCommunity);

module.exports = router;