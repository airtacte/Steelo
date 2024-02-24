const express = require('express');
const PaymentService = require('../../../services/PaymentService'); // Assuming the path
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
router.get('/payments', authorize, async (req, res) => {
        try {
                const payments = await PaymentService.getPayments();
                res.json(payments);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

// Process fiat payment
router.post('/fiat', authorize, validateInput, async (req, res) => {
        try {
                const payment = await PaymentService.fiatPayment(req.user, req.body);
                res.status(201).json(payment);
        } catch (error) {
                res.status(500).send(error.message);
        }
});

module.exports = router;