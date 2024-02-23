const express = require('express');
const UtilsService = require('../../../services/UtilsService'); // Assuming the path
const router = express.Router();

// Get common utilities
router.get('/common', async (req, res) => {
    try {
        const commonUtils = await UtilsService.getCommonUtils();
        res.json(commonUtils);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;