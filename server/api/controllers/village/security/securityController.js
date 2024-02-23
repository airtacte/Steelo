const express = require('express');
const SecurityService = require('../../../services/SecurityService'); // Assuming the path
const router = express.Router();

// Update security settings
router.put('/:id/security', async (req, res) => {
    try {
        const settings = await SecurityService.updateSecuritySettings(req.params.id, req.body);
        res.json(settings);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;