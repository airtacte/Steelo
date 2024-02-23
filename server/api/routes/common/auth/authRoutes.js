const express = require('express');
const authController = require('../../controllers/common/auth/authController'); // Assuming the path
const router = express.Router();

// Route to handle user registration via Firebase and blockchain account linking
router.post('/common/register', authController.register);

// Route to handle user login and token generation
router.post('/common/login', authController.login);

// Route to validate and refresh JWT tokens
router.post('/common/token', authController.token);

module.exports = router;