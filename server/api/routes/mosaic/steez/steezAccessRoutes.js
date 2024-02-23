const express = require('express');
const router = express.Router();
const steezAccessController = require('../../controllers/mosaic/steez/steezAccessController');

router.get('/details/:steezId', steezAccessController.getSteezDetails);
router.post('/transfer', steezAccessController.transferSteez);

module.exports = router;