const express = require('express');
const router = express.Router();
const giftController = require('../../controllers/gallery/transactions/giftController');

router.post('/gift/send', giftController.sendGift);
router.post('/gift/receive', giftController.receiveGift);
router.get('/gift/history', giftController.getGiftHistory);

module.exports = router;