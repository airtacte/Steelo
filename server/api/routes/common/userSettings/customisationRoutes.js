const express = require('express');
const customisationController = require('../../controllers/common/userSettings/customisationController');
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
router.get('/common/userSettings/customisation', authorize, customisationController.getCustomisation);

// Update background hue
router.put('/common/userSettings/customisation/background', authorize, validateInput, customisationController.updateBackgroundHue);

// Update display name
router.put('/common/userSettings/customisation/displayname', authorize, validateInput, customisationController.updateDisplayName);

module.exports = router;