const express = require('express');
const router = express.Router();
const { updateCollection } = require('../../controllers/gallery/collection/collectionUpdateController');

router.put('/:collectionId', updateCollection);

module.exports = router;