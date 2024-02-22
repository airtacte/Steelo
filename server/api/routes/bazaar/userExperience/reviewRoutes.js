const express = require('express');
const router = express.Router();
const reviewController = require('../../controllers/bazaar/userExperience/reviewController');

router.post('/', reviewController.postReview);
router.put('/:reviewId', reviewController.editReview);
router.delete('/:reviewId', reviewController.deleteReview);

module.exports = router;