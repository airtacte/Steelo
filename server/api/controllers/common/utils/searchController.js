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

// Get search results
router.get('/search', authorize, async (req, res) => {
        try {
                const searchParams = req.query;
                const searchResults = await UtilsService.getSearchResults(req.user, searchParams);
                res.json(searchResults);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

module.exports = router;