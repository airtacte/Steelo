const express = require('express');
const PortfolioService = require('../../../services/PortfolioService'); // Assuming the path
const router = express.Router();

// Get portfolio insights
router.get('/:id/insights', async (req, res) => {
    try {
        const insights = await PortfolioService.getInsights(req.params.id);
        res.json(insights);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;