const express = require('express');
const router = express.Router();
const contentUpdateController = require('../../controllers/mosaic/management/contentUpdateController');

router.put('/update/:contentId', contentUpdateController.updateContent);

module.exports = router;