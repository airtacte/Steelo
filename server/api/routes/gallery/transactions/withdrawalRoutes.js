const express = require('express');
const router = express.Router();
const withdrawalController = require('../../controllers/gallery/transactions/withdrawalController');

router.post('/withdraw/initiate', withdrawalController.initiateWithdrawal);
router.post('/withdraw/confirm', withdrawalController.confirmWithdrawal);
router.get('/withdraw/history', withdrawalController.getWithdrawalHistory);

module.exports = router;