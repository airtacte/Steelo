const express = require('express');
const NotificationService = require('../../../services/NotificationService'); // Assuming the path
const router = express.Router();

// Get notifications
router.get('/notifications', async (req, res) => {
    try {
        const notifications = await NotificationService.getNotifications();
        res.json(notifications);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;