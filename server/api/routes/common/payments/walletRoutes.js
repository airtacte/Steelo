const express = require('express');
const walletController = require('../../controllers/common/payments/walletController');
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

// Get wallet details
router.get('/common/payments/wallet', authorize, walletController.getWalletDetails);

// Process crypto payment
router.post('/common/payments/wallet/crypto', authorize, validateInput, walletController.processCryptoPayment);

module.exports = router;