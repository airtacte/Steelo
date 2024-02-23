const express = require('express');
const feedbackCollectionController = require('../../controllers/village/feedback/feedbackCollectionController');
const router = express.Router();

// Collect feedback
router.post('/village/:id/feedback', feedbackCollectionController.collectFeedback);

module.exports = router;