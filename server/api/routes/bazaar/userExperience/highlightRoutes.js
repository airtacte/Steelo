const express = require('express');
const router = express.Router();
const highlightController = require('../../controllers/bazaar/userExperience/highlightController');

router.get('/', highlightController.getHighlights);
router.post('/', highlightController.addHighlight);

module.exports = router;