const express = require('express');
const { tradeAssets, getExchangeRates } = require('../../controllers/bazaar/transactions/exchangeController');
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

router.post('/trade', authorize, validateInput, tradeAssets);
router.get('/rates', authorize, getExchangeRates);

module.exports = router;