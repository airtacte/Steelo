const express = require('express');
const router = express.Router();
const collectionSettingsController = require('../../controllers/mosaic/management/collectionSettingsController');

router.put('/settings', collectionSettingsController.updateSettings);
router.get('/settings/:collectionId', collectionSettingsController.getSettings);

module.exports = router;