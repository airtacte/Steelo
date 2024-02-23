const express = require('express');
const AdminService = require('../../../services/AdminService'); // Assuming the path
const router = express.Router();

// Control content
router.put('/:id/contentControl', async (req, res) => {
    try {
        const control = await AdminService.controlContent(req.params.id, req.body);
        res.json(control);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;