const express = require('express');
const profileVerificationController = require('../../controllers/profile/verification/profileVerificationController');
const router = express.Router();

// Verify profile
router.put('/profile/:id/verify', profileVerificationController.verifyProfile);

module.exports = router;