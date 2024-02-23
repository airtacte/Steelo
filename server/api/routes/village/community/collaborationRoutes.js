const express = require('express');
const collaborationController = require('../../controllers/village/community/collaborationController');
const router = express.Router();

// Collaborate
router.post('/village/community/:id/collaborate', collaborationController.collaborate);

module.exports = router;