const express = require('express');
const UtilsService = require('../../../services/UtilsService'); // Assuming the path
const router = express.Router();

// Get filters
router.get('/filters', async (req, res) => {
    try {
        const filters = await UtilsService.getFilters();
        res.json(filters);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;