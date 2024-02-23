const express = require('express');
const MessagingService = require('../../../services/MessagingService'); // Assuming the path
const router = express.Router();

// Send notification
router.post('/:id/notification', async (req, res) => {
    try {
        const notification = await MessagingService.sendNotification(req.params.id, req.body);
        res.status(201).json(notification);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;