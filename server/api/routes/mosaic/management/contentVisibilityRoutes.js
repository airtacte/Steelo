const express = require('express');
const router = express.Router();
const contentVisibilityController = require('../../controllers/mosaic/management/contentVisibilityController');

router.put('/visibility/:contentId', contentVisibilityController.setVisibility);

module.exports = router;