const express = require('express');
const FollowerService = require('../../../services/FollowerService'); // Assuming the path
const router = express.Router();

// Display followers
router.get('/', async (req, res) => {
    try {
        const followers = await FollowerService.getFollowers(req.user.id);
        res.json(followers);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;