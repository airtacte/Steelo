const express = require('express');
const SpaceService = require('../../../services/SpaceService'); // Assuming the path
const router = express.Router();

// Delete space
router.delete('/:id', async (req, res) => {
    try {
        await SpaceService.deleteSpace(req.params.id);
        res.status(204).send();
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;