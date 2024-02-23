const express = require('express');
const SecurityService = require('../../../services/SecurityService'); // Assuming the path
const router = express.Router();

// Report incident
router.post('/:id/incident', async (req, res) => {
    try {
        const incident = await SecurityService.reportIncident(req.params.id, req.body);
        res.status(201).json(incident);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;