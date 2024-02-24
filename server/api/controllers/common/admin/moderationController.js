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

// Moderate content
router.put('/:id/moderate', [
    authorize,
    body('content').notEmpty().withMessage('Content is required'),
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const moderation = await AdminService.moderateContent(req.params.id, req.body);
            res.json(moderation);
        } catch (error) {
            res.status(500).send(error.message);
        }
    }
]);

module.exports = router;