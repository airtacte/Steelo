const express = require('express');
const CollabUpdateService = require('../../../services/CollabUpdateService'); // Assuming the path
const router = express.Router();

// Update a collaboration
router.put('/:id', async (req, res) => {
    try {
        const updatedCollab = await CollabUpdateService.updateCollab(req.params.id, req.body);
        res.json(updatedCollab);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;