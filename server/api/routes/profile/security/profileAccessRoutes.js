const express = require('express');
const profileAccessController = require('../../controllers/profile/security/profileAccessController');
const router = express.Router();

// Update profile access
router.put('/profile/:id/access', profileAccessController.updateAccess);

module.exports = router;