const express = require('express');
const feedbackResponseController = require('../../controllers/village/feedback/feedbackResponseController');
const router = express.Router();

// Respond to feedback
router.put('/village/feedback/:id/response', feedbackResponseController.respondFeedback);

module.exports = router;