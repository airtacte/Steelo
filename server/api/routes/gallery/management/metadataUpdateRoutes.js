const express = require('express');
const router = express.Router();
const metadataUpdateController = require('../../controllers/gallery/management/metadataUpdateController');

router.put('/updateMetadata', metadataUpdateController.updateMetadata);

module.exports = router;