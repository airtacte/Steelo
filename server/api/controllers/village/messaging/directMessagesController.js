const express = require('express');
const DirectMessagesModel = require('../models/DirectMessagesModel');
const router = express.Router();

// Fetch all direct messages between two users
router.get('/:senderId/:receiverId/messages', async (req, res) => {
    try {
        const senderId = req.params.senderId;
        const receiverId = req.params.receiverId;
        const messages = await DirectMessagesModel.find({
            $or: [
                {senderId: senderId, receiverId: receiverId},
                {senderId: receiverId, receiverId: senderId}
            ]
        }).sort({timestamp: 'asc'});
        res.status(200).json(messages);
    } catch (error) {
        res.status(500).json({message: 'Error fetching direct messages.', error: error});
    }
});

// Send a direct message
router.post('/:senderId/:receiverId/message', async (req, res) => {
    try {
        const message = new DirectMessagesModel(req.body);
        await message.save();
        res.status(201).json({message: 'Direct message sent successfully.'});
    } catch (error) {
        res.status(500).json({message: 'Error sending direct message.', error: error});
    }
});

module.exports = router;