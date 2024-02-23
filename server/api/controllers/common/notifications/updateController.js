const express = require('express');
const NotificationService = require('../../../services/NotificationService'); // Assuming the path
const router = express.Router();

// Get updates
router.get('/updates', async (req, res) => {
    try {
        const updates = await NotificationService.getUpdates();
        res.json(updates);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;