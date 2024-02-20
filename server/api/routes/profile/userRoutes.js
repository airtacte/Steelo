const express = require('express');
const router = express.Router();
const authMiddleware = require('../Middleware/authMiddleware');
const authController = require('../Controllers/authController');

// Sample endpoint requiring authentication
router.get('/currentUser', authMiddleware, (req, res) => {
    res.send(req.user);
});

// New endpoints for user registration and login
router.post('/register', authController.register);
router.post('/login', authController.login);

module.exports = router;