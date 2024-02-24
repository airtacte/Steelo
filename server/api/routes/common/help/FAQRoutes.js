const express = require('express');
const FAQController = require('../../controllers/common/help/FAQController');
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


// Get FAQs
router.get('/common/help/faqs', authorize, FAQController.getFAQs);

// Post to chat
router.post('/common/help/chat', authorize, validateInput, FAQController.postToChat);

module.exports = router;