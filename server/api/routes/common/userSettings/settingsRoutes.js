const express = require('express');
const settingsController = require('../../controllers/common/userSettings/settingsController');
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

// Get settings
router.get('/common/userSettings/settings', authorize, settingsController.getSettings);

// Get and update privacy settings
router.get('/common/userSettings/settings/privacy', authorize, settingsController.getPrivacySettings);
router.put('/common/userSettings/settings/privacy', authorize, validateInput, settingsController.updatePrivacySettings);

// Get and update notification settings
router.get('/common/userSettings/settings/notifications', authorize, settingsController.getNotificationSettings);
router.put('/common/userSettings/settings/notifications', authorize, validateInput, settingsController.updateNotificationSettings);

// Get and update contact preferences
router.get('/common/userSettings/settings/contact', authorize, settingsController.getContactPreferences);
router.put('/common/userSettings/settings/contact', authorize, validateInput, settingsController.updateContactPreferences);

// Update login credentials
router.put('/common/userSettings/settings/login', authorize, validateInput, settingsController.updateLoginCredentials);

module.exports = router;