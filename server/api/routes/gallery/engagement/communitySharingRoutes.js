const express = require('express');
const router = express.Router();
const { shareWithCommunity } = require('../../controllers/gallery/engagement/communitySharingController');

router.post('/share', shareWithCommunity);

module.exports = router;