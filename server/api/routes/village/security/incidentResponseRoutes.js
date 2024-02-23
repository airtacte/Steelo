const express = require('express');
const incidentResponseController = require('../../controllers/village/security/incidentResponseController');
const router = express.Router();

// Report incident
router.post('/village/:id/incident', incidentResponseController.reportIncident);

module.exports = router;