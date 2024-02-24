const express = require('express');
const notificationController = require('../../controllers/common/notifications/notificationController');
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

  
// Get notifications
router.get('/common/notifications/notifications', authorize, notificationController.getNotifications);

// Subscribe to notifications
router.post('/common/notifications/subscribe', authorize, validateInput, notificationController.subscribeToNotifications);

module.exports = router;