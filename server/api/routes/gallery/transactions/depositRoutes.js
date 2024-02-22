const express = require('express');
const router = express.Router();
const depositController = require('../../controllers/gallery/transactions/depositController');

router.post('/deposit/initiate', depositController.initiateDeposit);
router.post('/deposit/confirm', depositController.confirmDeposit);
router.get('/deposit/history', depositController.getDepositHistory);

module.exports = router;