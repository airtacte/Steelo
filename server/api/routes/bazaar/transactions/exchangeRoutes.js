const express = require('express');
const { tradeAssets, getExchangeRates } = require('../../controllers/bazaar/transactions/exchangeController');
const router = express.Router();

router.post('/trade', tradeAssets);
router.get('/rates', getExchangeRates);

module.exports = router;