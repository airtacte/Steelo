const express = require('express');
const paymentController = require('../../controllers/common/payments/paymentController');
const router = express.Router();

// Get payments
router.get('/common/payments/payments', paymentController.getPayments);

module.exports = router;