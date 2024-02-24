const express = require('express');
const cryptoController = require('../../controllers/common/payments/cryptoController');
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

  
// Get crypto payments
router.get('/common/payments/crypto', authorize, cryptoController.getCryptoPayments);
router.get('/common/payments/crypto/:id', authorize, validateInput, cryptoController.getCryptoPayment);

module.exports = router;