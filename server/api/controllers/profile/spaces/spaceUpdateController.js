const express = require('express');
const SpaceService = require('../../../services/SpaceService'); // Assuming the path
const router = express.Router();

// Update space
router.put('/:id', async (req, res) => {
    try {
        const space = await SpaceService.updateSpace(req.params.id, req.body);
        res.json(space);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;