const express = require('express');
const accessManagementController = require('../../controllers/village/community/accessManagementController');
const router = express.Router();

// Manage access
router.put('/village/community/:id/access', accessManagementController.manageAccess);

module.exports = router;