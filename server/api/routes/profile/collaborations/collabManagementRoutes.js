const express = require('express');
const collabManagementController = require('../../controllers/profile/collaborations/collabManagementController');
const router = express.Router();

// Add collaboration
router.post('/profile/collaborations', collabManagementController.addCollab);

// Remove collaboration
router.delete('/profile/collaborations/:id', collabManagementController.removeCollab);

module.exports = router;