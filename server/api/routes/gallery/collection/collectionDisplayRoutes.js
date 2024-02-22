const express = require('express');
const router = express.Router();
const { displayCollection } = require('../../controllers/gallery/collection/collectionDisplayController');

router.get('/:collectionId', displayCollection);

module.exports = router;