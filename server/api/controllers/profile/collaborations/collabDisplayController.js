const express = require('express');
const CollabDisplayService = require('../../../services/CollabDisplayService'); // Assuming the path
const router = express.Router();

// Display collaborations
router.get('/:id', async (req, res) => {
    try {
        const collabs = await CollabDisplayService.getCollabs(req.params.id);
        res.json(collabs);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;