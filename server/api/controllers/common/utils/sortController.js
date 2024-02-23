const express = require('express');
const UtilsService = require('../../../services/UtilsService'); // Assuming the path
const router = express.Router();

// Get sorted results
router.get('/sort', async (req, res) => {
    try {
        const sortedResults = await UtilsService.getSortedResults(req.query);
        res.json(sortedResults);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;