const express = require('express');
const spaceDeletionController = require('../../controllers/profile/spaces/spaceDeletionController');
const router = express.Router();

// Delete space
router.delete('/profile/spaces/:id', spaceDeletionController.deleteSpace);

module.exports = router;