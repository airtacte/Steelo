const express = require('express');
const spaceDisplayController = require('../../controllers/profile/spaces/spaceDisplayController');
const router = express.Router();

// Display space
router.get('/profile/spaces/:id', spaceDisplayController.getSpace);

module.exports = router;