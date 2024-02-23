const express = require('express');
const CommunityChatModel = require('../models/CommunityChatModel');
const router = express.Router();

// Fetch all chat messages for a given community
router.get('/:chatId/messages', async (req, res) => {
    try {
        const chatId = req.params.chatId;
        const messages = await CommunityChatModel.find({chatId: chatId}).sort({timestamp: 'asc'});
        res.status(200).json(messages);
    } catch (error) {
        res.status(500).json({message: 'Error fetching community chat messages.', error: error});
    }
});

// Send a message to the community chat
router.post('/:chatId/message', async (req, res) => {
    try {
        const message = new CommunityChatModel(req.body);
        await message.save();
        res.status(201).json({message: 'Message sent successfully.'});
    } catch (error) {
        res.status(500).json({message: 'Error sending message.', error: error});
    }
});

module.exports = router;