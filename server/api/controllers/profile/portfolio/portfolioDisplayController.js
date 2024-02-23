const express = require('express');
const PortfolioService = require('../../../services/PortfolioService'); // Assuming the path
const router = express.Router();

// Display portfolio
router.get('/:id', async (req, res) => {
    try {
        const portfolio = await PortfolioService.getPortfolio(req.params.id);
        res.json(portfolio);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;