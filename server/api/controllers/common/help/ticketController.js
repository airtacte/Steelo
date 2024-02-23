const express = require('express');
const HelpService = require('../../../services/HelpService'); // Assuming the path
const router = express.Router();

// Submit a ticket
router.post('/ticket', async (req, res) => {
    try {
        const ticket = await HelpService.submitTicket(req.body);
        res.status(201).json(ticket);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;