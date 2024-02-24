const express = require('express');
const { addOrder, removeOrder } = require('../../controllers/bazaar/transactions/OrderBookController');
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

router.post('/add', authorize, validateInput, addOrder);
router.post('/remove', authorize, validateInput, removeOrder);

module.exports = router;