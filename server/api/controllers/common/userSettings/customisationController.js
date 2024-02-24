const express = require('express');
const UserSettingsService = require('../../../services/UserSettingsService'); // Assuming the path
const router = express.Router();

// Middleware for user authorization
const authorize = (req, res, next) => {
  if (!req.user) {
    return res.status(403).send('You do not have permission to perform this action');
  }
  next();
};

// Middleware for input validation
const validateInput = (req, res, next) => {
  // Add your input validation logic here
  next();
};

// Get customisation settings
router.get('/customisation', authorize, async (req, res) => {
    try {
        const customisation = await UserSettingsService.getCustomisation(req.user);
        res.json(customisation);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Update background hue
router.put('/customisation/background', authorize, validateInput, async (req, res) => {
    try {
        const updatedCustomisation = await UserSettingsService.updateBackgroundHue(req.user, req.body);
        res.json(updatedCustomisation);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Update display name
router.put('/customisation/displayname', authorize, validateInput, async (req, res) => {
    try {
        const updatedCustomisation = await UserSettingsService.updateDisplayName(req.user, req.body);
        res.json(updatedCustomisation);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;