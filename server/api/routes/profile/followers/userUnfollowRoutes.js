const express = require('express');
const userUnfollowController = require('../../controllers/profile/followers/userUnfollowController');
const router = express.Router();

// Unfollow a user
router.delete('/profile/unfollow/:id', userUnfollowController.unfollowUser);

module.exports = router;