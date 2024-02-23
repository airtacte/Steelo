const express = require('express');
const FAQController = require('../../controllers/common/help/FAQController');
const router = express.Router();

// Get FAQs
router.get('/common/help/faqs', FAQController.getFAQs);

module.exports = router;