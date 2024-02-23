const express = require('express');
const notificationController = require('../../controllers/common/notifications/notificationController');
const router = express.Router();

// Get notifications
router.get('/common/notifications/notifications', notificationController.getNotifications);

module.exports = router;