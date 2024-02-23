const express = require('express');
const CollabManagementService = require('../../../services/CollabManagementService'); // Assuming the path
const router = express.Router();

// Add collaboration
router.post('/', async (req, res) => {
    try {
        const collab = await CollabManagementService.addCollab(req.body);
        res.status(201).json(collab);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Remove collaboration
router.delete('/:id', async (req, res) => {
    try {
        await CollabManagementService.removeCollab(req.params.id);
        res.status(204).send();
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;