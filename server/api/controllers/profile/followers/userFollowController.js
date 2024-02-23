const express = require('express');
const FollowerService = require('../../../services/FollowerService'); // Assuming the path
const router = express.Router();

// Follow a user
router.post('/:id', async (req, res) => {
    try {
        await FollowerService.followUser(req.user.id, req.params.id);
        res.status(204).send();
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;