const express = require('express');
const router = express.Router();
const { tradeSteez } = require('../../controllers/gallery/steez/steezTradeController');

router.post('/trade', tradeSteez);

module.exports = router;