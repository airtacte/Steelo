const express = require('express');
const notificationController = require('../../controllers/village/messaging/notificationController');
const router = express.Router();

// Send notification
router.post('/village/:id/notification', notificationController.sendNotification);

module.exports = router;