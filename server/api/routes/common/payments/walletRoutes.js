const express = require('express');
const walletController = require('../../controllers/common/payments/walletController');
const router = express.Router();

// Get wallet details
router.get('/common/payments/wallet', walletController.getWalletDetails);

module.exports = router;