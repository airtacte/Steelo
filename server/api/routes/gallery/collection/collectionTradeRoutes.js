const express = require('express');
const router = express.Router();
const collectionTradeController = require('../../controllers/gallery/collection/collectionTradeController');

router.post('/initiate', collectionTradeController.initiateTrade);
router.post('/complete', collectionTradeController.completeTrade);

module.exports = router;