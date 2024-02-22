const express = require('express');
const router = express.Router();
const { uploadSteez } = require('../../controllers/gallery/management/steezUploadController');

router.post('/uploadSteez', uploadSteez);

module.exports = router;