const express = require('express');
const SpaceService = require('../../../services/SpaceService'); // Assuming the path
const router = express.Router();

// Display space
router.get('/:id', async (req, res) => {
    try {
        const space = await SpaceService.getSpace(req.params.id);
        res.json(space);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;