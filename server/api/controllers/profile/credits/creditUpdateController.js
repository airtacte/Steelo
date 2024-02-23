const express = require('express');
const CreditUpdateService = require('../../../services/CreditUpdateService'); // Assuming the path
const router = express.Router();

// Update credits
router.put('/', async (req, res) => {
    try {
        const updatedCredits = await CreditUpdateService.updateCredits(req.user.id, req.body.amount);
        res.json(updatedCredits);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;