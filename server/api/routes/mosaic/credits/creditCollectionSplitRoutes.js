const express = require('express');
const router = express.Router();
const creditCollectionSplitController = require('../../controllers/mosaic/credits/creditCollectionSplitController');

router.post('/split', creditCollectionSplitController.splitCollectionCredits);

module.exports = router;