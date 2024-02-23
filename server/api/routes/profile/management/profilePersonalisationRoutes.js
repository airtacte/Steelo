const express = require('express');
const profilePersonalisationController = require('../../controllers/profile/management/profilePersonalisationController');
const router = express.Router();

// Personalise profile
router.put('/profile/personalise/:id', profilePersonalisationController.personaliseProfile);

module.exports = router;//Ensure that profilePersonalisationController.js covers all aspects of user personalization beyond visual elements, like notification settings or content preferences.