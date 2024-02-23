const express = require('express');
const InvestorUpdateService = require('../../../services/InvestorUpdateService'); // Assuming the path
const router = express.Router();

// Get incoming investments
router.get('/incoming', async (req, res) => {
    try {
        const investments = await InvestorUpdateService.getIncomingInvestments(req.user.id);
        res.json(investments);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Acknowledge investment
router.put('/acknowledge/:id', async (req, res) => {
    try {
        await InvestorUpdateService.acknowledgeInvestment(req.params.id);
        res.status(204).send();
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Decline investment
router.put('/decline/:id', async (req, res) => {
    try {
        await InvestorUpdateService.declineInvestment(req.params.id);
        res.status(204).send();
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;