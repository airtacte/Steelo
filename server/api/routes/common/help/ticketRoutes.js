const express = require('express');
const ticketController = require('../../controllers/common/help/ticketController');
const router = express.Router();

// Submit a ticket
router.post('/common/help/ticket', ticketController.submitTicket);

module.exports = router;