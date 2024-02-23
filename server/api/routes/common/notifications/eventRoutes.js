const express = require('express');
const eventController = require('../../controllers/common/notifications/eventController');
const router = express.Router();

// Get events
router.get('/common/notifications/events', eventController.getEvents);

module.exports = router;