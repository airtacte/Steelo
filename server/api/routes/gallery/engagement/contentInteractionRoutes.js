const express = require('express');
const router = express.Router();
const { likeContent, commentOnContent } = require('../../controllers/gallery/engagement/contentInteractionController');

router.post('/like', likeContent);
router.post('/comment', commentOnContent);

module.exports = router;