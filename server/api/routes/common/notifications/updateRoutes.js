const express = require('express');
const updateController = require('../../controllers/common/notifications/updateController');
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

// Get updates
router.get('/common/notifications/updates', authorize, updateController.getUpdates);

// Subscribe to updates
router.post('/common/notifications/subscribe', authorize, validateInput, updateController.subscribeToUpdates);

module.exports = router;