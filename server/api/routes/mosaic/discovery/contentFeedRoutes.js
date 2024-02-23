const express = require('express');
const router = express.Router();
const contentFeedController = require('../../controllers/mosaic/discovery/contentFeedController');

router.get('/feed', contentFeedController.getContentFeed);

module.exports = router;