const express = require('express');
const router = express.Router();
const authMiddleware = require('../Middleware/authMiddleware');

// Sample endpoint requiring authentication
router.get('/currentUser', authMiddleware, (req, res) => {
    res.send(req.user);
});

module.exports = router;
