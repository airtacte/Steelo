const express = require('express');
const router = express.Router();
const { checkCompliance } = require('../../controllers/bazaar/security/complianceController');

// Route for checking content compliance
router.get('/check/:contentId', checkCompliance);

module.exports = router;