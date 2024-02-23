const express = require('express');
const contentControlController = require('../../controllers/common/admin/contentControlController');
const router = express.Router();

// Control content
router.put('/common/:id/contentControl', contentControlController.controlContent);

module.exports = router;