const express = require('express');
const profileVisibilityController = require('../../controllers/profile/management/profileVisibilityController');
const router = express.Router();

// Update profile visibility
router.put('/profile/visibility/:id', profileVisibilityController.updateVisibility);

module.exports = router;