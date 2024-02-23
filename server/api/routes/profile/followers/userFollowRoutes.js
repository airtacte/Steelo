const express = require('express');
const userFollowController = require('../../controllers/profile/followers/userFollowController');
const router = express.Router();

// Follow a user
router.post('/profile/follow/:id', userFollowController.followUser);

module.exports = router;