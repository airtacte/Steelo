const express = require('express');
const CreditDisplayService = require('../../../services/CreditDisplayService'); // Assuming the path
const router = express.Router();

// Display credits
router.get('/', async (req, res) => {
    try {
        const credits = await CreditDisplayService.getCredits(req.user.id);
        res.json(credits);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;