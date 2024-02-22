const express = require('express');
const { addOrder, removeOrder } = require('../../controllers/bazaar/transactions/OrderBookController');
const router = express.Router();

router.post('/add', addOrder);
router.post('/remove', removeOrder);

module.exports = router;