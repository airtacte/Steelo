const express = require('express');
const { initiatePurchase, completePurchase, convertToCrypto } = require('../../controllers/bazaar/transactions/PurchaseController');
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

router.post('/initiate', authorize, validateInput, initiatePurchase);
router.post('/complete', authorize, validateInput, completePurchase);
router.post('/cancel', authorize, validateInput, cancelPurchase);
router.post('/convert', authorize, validateInput, async (req, res) => {
    try {
        const { amount } = req.body;
        const cryptoAmount = await convertToCrypto(amount);
        res.status(200).json({ cryptoAmount });
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;