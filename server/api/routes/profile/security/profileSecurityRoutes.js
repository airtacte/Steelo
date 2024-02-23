const express = require('express');
const profileSecurityController = require('../../controllers/profile/security/profileSecurityController');
const router = express.Router();

// Update profile security
router.put('/profile/:id/security', profileSecurityController.updateSecurity);

module.exports = router;