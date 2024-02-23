const express = require('express');
const securityController = require('../../controllers/village/security/securityController');
const router = express.Router();

// Update security settings
router.put('/village/:id/security', securityController.updateSecuritySettings);

module.exports = router;