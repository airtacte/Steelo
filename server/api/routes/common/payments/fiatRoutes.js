const express = require('express');
const fiatController = require('../../controllers/common/payments/fiatController');
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

// Get payments
router.get('/common/payments/payments', authorize, fiatController.getPayments);

// Process crypto payment
router.post('/common/payments/crypto', authorize, validateInput, fiatController.processCryptoPayment);

module.exports = router;