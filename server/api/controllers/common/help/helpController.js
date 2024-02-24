const express = require('express');
const HelpService = require('../../../services/HelpService'); // Assuming the path
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

// Get help resources
router.get('/resources', authorize, validateInput, async (req, res) => {
        try {
                const resources = await HelpService.getHelpResources();
                res.json(resources);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

module.exports = router;