const express = require('express');
const authController = require('../../controllers/common/auth/authController'); // Assuming the path
const router = express.Router();

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

// Route to handle user registration via Firebase and blockchain account linking
router.post('/common/register', authorize, validateInput, authController.register);

// Route to handle user login and token generation
router.post('/common/login', authorize, validateInput, authController.login);

// Route to validate and refresh JWT tokens
router.post('/common/token', authorize, validateInput, authController.token);

module.exports = router;