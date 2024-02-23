const express = require('express');
const eventController = require('../../controllers/village/community/eventController');
const router = express.Router();

// Create event
router.post('/village/community/:id/event', eventController.createEvent);

module.exports = router;