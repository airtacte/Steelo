const express = require('express');
const { initiatePurchase, completePurchase } = require('../../controllers/bazaar/transactions/PurchaseController');
const router = express.Router();

router.post('/initiate', initiatePurchase);
router.post('/complete', completePurchase);
router.post('/cancel', cancelPurchase);

module.exports = router;