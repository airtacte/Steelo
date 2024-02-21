const express = require('express');
const router = express.Router();
const firebaseAuth = require('../../services/firebaseAuth');
const web3Service = require('../../services/web3Service');
const jwt = require('jsonwebtoken');

// Middleware to validate web3 token
const { validateWeb3Token } = require('../../middleware/authMiddleware');

// Route to handle user registration via Firebase and blockchain account linking
router.post('/register', async (req, res) => {
    try {
        const { email, password, blockchainAddress } = req.body;
        const userCredential = await firebaseAuth.register(email, password);
        const token = jwt.sign({ uid: userCredential.user.uid }, process.env.JWT_SECRET, { expiresIn: '1h' });

        // Link blockchain address with Firebase user
        await web3Service.linkBlockchainAddress(userCredential.user.uid, blockchainAddress);

        res.status(201).json({ token, uid: userCredential.user.uid, blockchainAddress });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Route to handle user login and token generation
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const userCredential = await firebaseAuth.login(email, password);
        const token = jwt.sign({ uid: userCredential.user.uid }, process.env.JWT_SECRET, { expiresIn: '1h' });

        res.status(200).json({ token, uid: userCredential.user.uid });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Route to validate and refresh JWT tokens
router.post('/token', validateWeb3Token, (req, res) => {
    // Assuming validateWeb3Token middleware validates the existing token and injects user info into req.user
    const newToken = jwt.sign({ uid: req.user.uid }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.status(200).json({ token: newToken });
});

module.exports = router;