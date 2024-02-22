const express = require('express');
const router = express.Router();
const { displayRoyalties } = require('../../controllers/bazaar/royalties/displayRoyaltiesController');

// Route for displaying royalties for a specific creator
router.get('/:creatorId', displayRoyalties);

module.exports = router;