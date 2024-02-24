const express = require('express');
const HelpService = require('../../../services/HelpService'); // Assuming the path
const ChatService = require('../../../services/ChatService'); // Assuming the path
const router = express.Router();

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user) {
        return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};

// Get FAQs
router.get('/faqs', authorize, async (req, res) => {
    try {
        const faqs = await HelpService.getFAQs();
        res.json(faqs);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Post to LLM-powered chat, different from a customer-support-solved ticket
router.post('/chat', authorize, async (req, res) => {
    try {
        const userMessage = req.body.message;
        const chatResponse = await ChatService.getChatResponse(userMessage);
        res.json(chatResponse);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;