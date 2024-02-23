const express = require('express');
const router = express.Router();
const contentSharingController = require('../../controllers/mosaic/userInteraction/contentSharingController');

router.post('/share', contentSharingController.shareContent);

module.exports = router;