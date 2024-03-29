const express = require('express');
const sortController = require('../../controllers/common/utils/sortController');
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

// Get sorted results
router.get('/common/utils/sort', authorize, sortController.getSortedResults);

module.exports = router;