const express = require('express');
const communityBoardController = require('../../controllers/village/community/communityBoardController');
const router = express.Router();

// Get community board
router.get('/village/community/:id/board', communityBoardController.getCommunityBoard);

module.exports = router;