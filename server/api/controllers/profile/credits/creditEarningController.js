const express = require('express');
const CreditEarningService = require('../../../services/CreditEarningService'); // Assuming the path
const router = express.Router();

// Earn credits
router.post('/', async (req, res) => {
    try {
        const newCredits = await CreditEarningService.earnCredits(req.user.id, req.body.amount);
        res.status(201).json(newCredits);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;