const express = require('express');
const eventController = require('../../controllers/common/notifications/eventController');
const router = express.Router();

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user) {
      return res.status(403).send('You do not have permission to perform this action');
    }
    next();
  };
  
  // Middleware for input validation
  const validateInput = (req, res, next) => {
    // Add your input validation logic here
    next();
  };

  
// Get events
router.get('/common/notifications/events', authorize, eventController.getEvents);

// Subscribe to event notifications
router.post('/common/notifications/subscribe', authorize, validateInput, eventController.subscribeToNotifications);

module.exports = router;