const express = require('express');
const collabUpdateController = require('../../controllers/profile/collaborations/collabUpdateController');
const router = express.Router();

// Update a collaboration
router.put('/profile/collaborations/:id', collabUpdateController.updateCollab);

module.exports = router;