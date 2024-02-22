const express = require('express');
const router = express.Router();
const recommendationController = require('../../controllers/bazaar/userExperience/recommendationController');

router.get('/:userId', recommendationController.getRecommendations);

module.exports = router;