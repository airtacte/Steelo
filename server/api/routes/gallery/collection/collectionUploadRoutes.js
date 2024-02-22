
const express = require('express');
const router = express.Router();
const { uploadCollection } = require('../../controllers/gallery/collection/collectionUploadController');

router.post('/', uploadCollection);

module.exports = router;