const express = require('express');
const PaymentService = require('../../../services/PaymentService'); // Assuming the path
const router = express.Router();

// Get crypto payments
router.get('/crypto', async (req, res) => {
    try {
        const cryptoPayments = await PaymentService.getCryptoPayments();
        res.json(cryptoPayments);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;