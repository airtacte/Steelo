const express = require('express');
const NotificationService = require('../../../services/NotificationService'); // Assuming the path
const router = express.Router();

// Get events
router.get('/events', async (req, res) => {
    try {
        const events = await NotificationService.getEvents();
        res.json(events);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;