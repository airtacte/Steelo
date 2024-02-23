const express = require('express');
const communityChatController = require('../../controllers/village/community/communityChatController'); // Assuming the path
const router = express.Router();

// Fetch all chat messages for a given community
router.get('/village/community/:chatId/messages', communityChatController.getChatMessages);

// Send a message to the community chat
router.post('/village/community/:chatId/message', communityChatController.sendMessage);

module.exports = router;