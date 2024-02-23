const express = require('express');
const collabDisplayController = require('../../controllers/profile/collaborations/collabDisplayController');
const router = express.Router();

// Display collaborations
router.get('/profile/:id/collaborations', collabDisplayController.getCollabs);

module.exports = router;