const express = require('express');
const directMessagesController = require('../../controllers/village/community/directMessagesController'); // Assuming the path
const router = express.Router();

// Fetch all direct messages between two users
router.get('/village/community/:senderId/:receiverId/messages', directMessagesController.getDirectMessages);

// Send a direct message
router.post('/village/community/:senderId/:receiverId/message', directMessagesController.sendDirectMessage);

module.exports = router;