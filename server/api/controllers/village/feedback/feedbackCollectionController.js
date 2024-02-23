const express = require('express');
const FeedbackService = require('../../../services/FeedbackService'); // Assuming the path
const router = express.Router();

// Collect feedback
router.post('/:id/feedback', async (req, res) => {
    try {
        const feedback = await FeedbackService.collectFeedback(req.params.id, req.body);
        res.status(201).json(feedback);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;