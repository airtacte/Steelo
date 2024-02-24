const express = require('express');
const AdminService = require('../../../services/AdminService'); // Assuming the path
const { body, validationResult } = require('express-validator');
const router = express.Router();

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};

// Update system settings
router.put('/:id/systemSetting', [
    authorize,
    body('settings').notEmpty().withMessage('Settings are required'),
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const settings = await AdminService.updateSystemSettings(req.params.id, req.body);
            res.json(settings);
        } catch (error) {
            res.status(500).send(error.message);
        }
    }
]);

module.exports = router;