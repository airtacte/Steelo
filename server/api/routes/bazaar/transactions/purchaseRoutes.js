const express = require('express');
const { initiatePurchase, completePurchase, convertToCrypto } = require('../../controllers/bazaar/transactions/PurchaseController');
const router = express.Router();

router.post('/initiate', initiatePurchase);
router.post('/complete', completePurchase);
router.post('/cancel', cancelPurchase);
router.post('/convert', async (req, res) => {
    try {
        const { amount } = req.body;
        const cryptoAmount = await convertToCrypto(amount);
        res.status(200).json({ cryptoAmount });
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;