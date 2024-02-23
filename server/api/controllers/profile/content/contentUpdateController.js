const express = require('express');
const ContentUpdateService = require('../../../services/ContentUpdateService'); // Assuming the path
const router = express.Router();

// Update content
router.put('/:id', async (req, res) => {
    try {
        const updatedContent = await ContentUpdateService.updateContent(req.params.id, req.body);
        res.json(updatedContent);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;