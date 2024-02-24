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

// Get settings
router.get('/settings', authorize, async (req, res) => {
        try {
                const settings = await UserSettingsService.getSettings(req.user);
                res.json(settings);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

// Get and update privacy settings
router.get('/settings/privacy', authorize, UserSettingsService.getPrivacySettings);
router.put('/settings/privacy', authorize, validateInput, UserSettingsService.updatePrivacySettings);

// Get and update notification settings
router.get('/settings/notifications', authorize, UserSettingsService.getNotificationSettings);
router.put('/settings/notifications', authorize, validateInput, UserSettingsService.updateNotificationSettings);

// Get and update contact preferences
router.get('/settings/contact', authorize, UserSettingsService.getContactPreferences);
router.put('/settings/contact', authorize, validateInput, UserSettingsService.updateContactPreferences);

// Update login credentials
router.put('/settings/login', authorize, validateInput, UserSettingsService.updateLoginCredentials);

module.exports = router;