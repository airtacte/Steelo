const express = require('express');
const FeedbackService = require('../../../services/FeedbackService'); // Assuming the path
const router = express.Router();

// Respond to feedback
router.put('/feedback/:id/response', async (req, res) => {
    try {
        const response = await FeedbackService.respondFeedback(req.params.id, req.body);
        res.json(response);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;