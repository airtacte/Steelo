const express = require('express');
const ContentDeletionService = require('../../../services/ContentDeletionService'); // Assuming the path
const router = express.Router();

// Delete content
router.delete('/:id', async (req, res) => {
    try {
        await ContentDeletionService.deleteContent(req.params.id);
        res.status(204).send();
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;