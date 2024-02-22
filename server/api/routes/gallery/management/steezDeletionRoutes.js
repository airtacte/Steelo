const express = require('express');
const router = express.Router();
const steezDeletionController = require('../../controllers/gallery/management/steezDeletionController');

router.delete('/deleteSteez', steezDeletionController.deleteSteez);

module.exports = router;