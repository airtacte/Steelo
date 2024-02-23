const express = require('express');
const UtilsService = require('../../../services/UtilsService'); // Assuming the path
const router = express.Router();

// Get search results
router.get('/search', async (req, res) => {
    try {
        const searchResults = await UtilsService.getSearchResults(req.query);
        res.json(searchResults);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;