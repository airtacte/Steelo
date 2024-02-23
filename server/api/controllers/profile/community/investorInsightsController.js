const express = require('express');
const InvestorInsightsService = require('../../../services/InvestorInsightsService'); // Assuming the path
const router = express.Router();

// Get investor insights
router.get('/:id', async (req, res) => {
    try {
        const insights = await InvestorInsightsService.getInsights(req.params.id);
        res.json(insights);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;