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

// Get preferences
router.get('/preferences', authorize, async (req, res) => {
        try {
                const preferences = await UserSettingsService.getPreferences(req.user);
                res.json(preferences);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

// Get and update privacy settings
router.get('/preferences/privacy', authorize, UserSettingsService.getPrivacySettings);
router.put('/preferences/privacy', authorize, validateInput, UserSettingsService.updatePrivacySettings);

// Get and update notification settings
router.get('/preferences/notifications', authorize, UserSettingsService.getNotificationSettings);
router.put('/preferences/notifications', authorize, validateInput, UserSettingsService.updateNotificationSettings);

// Get and update contact preferences
router.get('/preferences/contact', authorize, UserSettingsService.getContactPreferences);
router.put('/preferences/contact', authorize, validateInput, UserSettingsService.updateContactPreferences);

// Update login credentials
router.put('/preferences/login', authorize, validateInput, UserSettingsService.updateLoginCredentials);

module.exports = router;