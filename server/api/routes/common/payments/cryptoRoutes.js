const express = require('express');
const cryptoController = require('../../controllers/common/payments/cryptoController');
const router = express.Router();

// Get crypto payments
router.get('/common/payments/crypto', cryptoController.getCryptoPayments);

module.exports = router;