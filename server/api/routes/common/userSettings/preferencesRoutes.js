const express = require('express');
const preferencesController = require('../../controllers/common/userSettings/preferencesController');
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

// Get preferences
router.get('/common/userSettings/preferences', authorize, preferencesController.getPreferences);

// Get and update privacy settings
router.get('/common/userSettings/preferences/privacy', authorize, preferencesController.getPrivacySettings);
router.put('/common/userSettings/preferences/privacy', authorize, validateInput, preferencesController.updatePrivacySettings);

// Get and update notification settings
router.get('/common/userSettings/preferences/notifications', authorize, preferencesController.getNotificationSettings);
router.put('/common/userSettings/preferences/notifications', authorize, validateInput, preferencesController.updateNotificationSettings);

// Get and update contact preferences
router.get('/common/userSettings/preferences/contact', authorize, preferencesController.getContactPreferences);
router.put('/common/userSettings/preferences/contact', authorize, validateInput, preferencesController.updateContactPreferences);

// Update login credentials
router.put('/common/userSettings/preferences/login', authorize, validateInput, preferencesController.updateLoginCredentials);

module.exports = router;