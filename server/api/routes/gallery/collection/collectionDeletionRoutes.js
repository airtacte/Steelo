const express = require('express');
const router = express.Router();
const { deleteCollection } = require('../../controllers/gallery/collection/collectionDeletionController');

router.delete('/:collectionId', deleteCollection);

module.exports = router;