const express = require('express');
const ticketController = require('../../controllers/common/help/ticketController');
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

  
// Submit a ticket
router.post('/common/help/ticket', authorize, validateInput, ticketController.submitTicket);

// Request a phone call
router.post('/common/help/request-call', authorize, validateInput, ticketController.requestCall);

// Request to be notified when someone is available
router.post('/common/help/request-notification', authorize, validateInput, ticketController.requestNotification);

module.exports = router;