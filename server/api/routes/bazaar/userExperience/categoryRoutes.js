const express = require('express');
const router = express.Router();
const categoryController = require('../../controllers/bazaar/userExperience/categoryController');

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

router.get('/', authorize, categoryController.getCategories);
router.post('/', authorize, validateInput, categoryController.addCategory);

module.exports = router;