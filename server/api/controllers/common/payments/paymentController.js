const express = require('express');
const PaymentService = require('../../../services/PaymentService'); // Assuming the path
const router = express.Router();

// Get payments
router.get('/payments', async (req, res) => {
    try {
        const payments = await PaymentService.getPayments();
        res.json(payments);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;