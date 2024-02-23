const express = require('express');
const router = express.Router();
const contentCollectionController = require('../../controllers/mosaic/userInteraction/contentCollectionController');

router.post('/', contentCollectionController.createCollection);
router.put('/add', contentCollectionController.addToCollection);
router.delete('/remove', contentCollectionController.removeFromCollection);

module.exports = router;