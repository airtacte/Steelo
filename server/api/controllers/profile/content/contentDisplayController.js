const express = require('express');
const ContentDisplayService = require('../../../services/ContentDisplayService'); // Assuming the path
const router = express.Router();

// Display content
router.get('/:id', async (req, res) => {
    try {
        const content = await ContentDisplayService.getContent(req.params.id);
        res.json(content);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;