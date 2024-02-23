const express = require('express');
const router = express.Router();
const contentPromotionController = require('../../controllers/mosaic/management/contentPromotionController');

router.post('/promote', contentPromotionController.promoteContent);

module.exports = router;