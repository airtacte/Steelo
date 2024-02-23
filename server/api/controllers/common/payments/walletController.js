const express = require('express');
const PaymentService = require('../../../services/PaymentService'); // Assuming the path
const router = express.Router();

// Get wallet details
router.get('/wallet', async (req, res) => {
    try {
        const wallet = await PaymentService.getWalletDetails();
        res.json(wallet);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;