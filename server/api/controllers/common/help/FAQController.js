const express = require('express');
const HelpService = require('../../../services/HelpService'); // Assuming the path
const router = express.Router();

// Get FAQs
router.get('/faqs', async (req, res) => {
    try {
        const faqs = await HelpService.getFAQs();
        res.json(faqs);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;