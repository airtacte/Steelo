const express = require('express');
const AdminService = require('../../../services/AdminService'); // Assuming the path
const router = express.Router();

// Update system settings
router.put('/:id/systemSetting', async (req, res) => {
    try {
        const settings = await AdminService.updateSystemSettings(req.params.id, req.body);
        res.json(settings);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;