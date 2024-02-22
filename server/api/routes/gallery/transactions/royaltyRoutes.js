const express = require('express');
const router = express.Router();
const royaltyController = require('../../controllers/gallery/transactions/royaltyController');

router.get('/calculate', royaltyController.calculateRoyalties);
router.post('/distribute', royaltyController.distributeRoyalties);

module.exports = router;