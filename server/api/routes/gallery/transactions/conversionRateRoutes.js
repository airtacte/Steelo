const express = require('express');
const router = express.Router();
const conversionRateController = require('../../controllers/gallery/transactions/conversionRateController');

router.get('/rates', conversionRateController.getConversionRates);

module.exports = router;