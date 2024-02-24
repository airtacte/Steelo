const express = require('express');
const HelpService = require('../../../services/HelpService'); // Assuming the path
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
router.post('/ticket', authorize, validateInput, async (req, res) => {
    try {
        const ticket = await HelpService.submitTicket(req.body);
        res.status(201).json(ticket);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Request a phone call
router.post('/request-call', authorize, validateInput, async (req, res) => {
    try {
        const callRequest = await HelpService.requestCall(req.user, req.body);
        res.status(201).json(callRequest);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Request to be notified when someone is available
router.post('/request-notification', authorize, validateInput, async (req, res) => {
    try {
        const notificationRequest = await HelpService.requestNotification(req.user);
        res.status(201).json(notificationRequest);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;