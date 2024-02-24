const express = require('express');
const UtilsService = require('../../../services/UtilsService'); // Assuming the path
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

// Get common utilities
router.get('/common', authorize, async (req, res) => {
        try {
                const commonUtils = await UtilsService.getCommonUtils(req.user);
                res.json(commonUtils);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

module.exports = router;