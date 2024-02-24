const express = require('express');
const router = express.Router();
const AuthService = require('../../../services/AuthService'); // Assuming the path
const web3Service = require('../../../services/web3Service'); // Assuming the path
const jwt = require('jsonwebtoken');
const { body } = require('express-validator');

// Middleware to validate web3 token
const { validateWeb3Token } = require('../../../middleware/authMiddleware'); // Assuming the path

// Route to handle user registration via Firebase and blockchain account linking
router.post('/register', [
    body('email').isEmail().withMessage('Invalid email'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('blockchainAddress').isString().withMessage('Invalid blockchain address'),
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const { email, password, blockchainAddress } = req.body;
            const userCredential = await AuthService.register(email, password);
            const token = jwt.sign({ uid: userCredential.user.uid }, process.env.JWT_SECRET, { expiresIn: '1h' });

            // Link blockchain address with Firebase user
            await web3Service.linkBlockchainAddress(userCredential.user.uid, blockchainAddress);

            res.status(201).json({ token, uid: userCredential.user.uid, blockchainAddress });
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }
]);

// Route to handle user login and token generation
router.post('/login', [
    body('email').isEmail().withMessage('Invalid email'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const { email, password } = req.body;
            const userCredential = await AuthService.login(email, password);
            const token = jwt.sign({ uid: userCredential.user.uid }, process.env.JWT_SECRET, { expiresIn: '1h' });

            res.status(200).json({ token, uid: userCredential.user.uid });
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }
]);

// Route to validate and refresh JWT tokens
router.post('/token', validateWeb3Token, (req, res) => {
    // Assuming validateWeb3Token middleware validates the existing token and injects user info into req.user
    const newToken = jwt.sign({ uid: req.user.uid }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.status(200).json({ token: newToken });
});

module.exports = router;