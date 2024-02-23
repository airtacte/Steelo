const express = require('express');
const spaceUpdateController = require('../../controllers/profile/spaces/spaceUpdateController');
const router = express.Router();

// Update space
router.put('/profile/spaces/:id', spaceUpdateController.updateSpace);

module.exports = router;