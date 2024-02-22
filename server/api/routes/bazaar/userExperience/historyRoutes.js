const express = require('express');
const router = express.Router();
const historyController = require('../../controllers/bazaar/userExperience/historyController');

router.get('/:userId', historyController.getUserHistory);
router.delete('/:userId', historyController.clearHistory);

module.exports = router;