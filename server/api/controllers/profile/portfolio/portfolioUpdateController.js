const express = require('express');
const PortfolioService = require('../../../services/PortfolioService'); // Assuming the path
const router = express.Router();

// Update portfolio
router.put('/:id', async (req, res) => {
    try {
        const portfolio = await PortfolioService.updatePortfolio(req.params.id, req.body);
        res.json(portfolio);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;