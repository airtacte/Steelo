const express = require('express');
const router = express.Router();
const reviewController = require('../../controllers/bazaar/userExperience/reviewController');
const { auth } = require('firebase-admin');

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user) {
      return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};
  
  // Middleware for input validation
  const validateInput = (req, res, next) => {
    // Add your input validation logic here
    next();
};


router.post('/', authorize, validateInput, reviewController.postReview);
router.put('/:reviewId', authorize, validateInput, reviewController.editReview);
router.delete('/:reviewId', authorize, reviewController.deleteReview);

module.exports = router;