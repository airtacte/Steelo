const express = require('express');
const router = express.Router();
const transactionsController = require('../../controllers/gallery/transactions/transactionsController');

router.post('/create', transactionsController.createTransaction);
router.get('/details', transactionsController.getTransactionDetails);
router.put('/update', transactionsController.updateTransaction);
router.delete('/delete', transactionsController.deleteTransaction);
router.get('/history', transactionsController.getTransactionHistory);

module.exports = router;