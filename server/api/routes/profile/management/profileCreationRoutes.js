const express = require('express');
const profileCreationController = require('../../controllers/profile/management/profileCreationController');
const router = express.Router();

// Create profile
router.post('/profile/create', profileCreationController.createProfile);

module.exports = router;