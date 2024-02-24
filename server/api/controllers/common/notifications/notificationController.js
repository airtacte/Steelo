const express = require('express');
const NotificationService = require('../../../services/NotificationService'); // Assuming the path
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

// Get notifications
router.get('/notifications', authorize, async (req, res) => {
        try {
                const notifications = await NotificationService.getNotifications();
                res.json(notifications);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

// Subscribe to notifications
router.post('/subscribe', authorize, validateInput, async (req, res) => {
        try {
                const subscription = await NotificationService.subscribeToNotifications(req.user, req.body);
                res.status(201).json(subscription);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

module.exports = router;