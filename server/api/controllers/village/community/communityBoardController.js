const express = require('express');
const CommunityService = require('../../../services/CommunityService'); // Assuming the path
const router = express.Router();

// Get community board
router.get('/:id/board', async (req, res) => {
    try {
        const board = await CommunityService.getCommunityBoard(req.params.id);
        res.json(board);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;