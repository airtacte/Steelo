const express = require('express');
const displayFollowersController = require('../../controllers/profile/followers/displayFollowersController');
const router = express.Router();

// Display followers
router.get('/profile/followers', displayFollowersController.getFollowers);

module.exports = router;