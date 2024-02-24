const express = require('express');
const WatchListService = require('../../../services/WatchListService'); // Assuming the path
const router = express.Router();

// Add item to watch list
router.post('/', async (req, res) => {
    try {
        const item = await WatchListService.addItem(req.user.id, req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Remove item from watch list
router.delete('/:id', async (req, res) => {
    try {
        await WatchListService.removeItem(req.user.id, req.params.id);
        res.status(204).send();
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Update item in watch list
router.put('/:id', async (req, res) => {
    try {
        const updatedItem = await WatchListService.updateItem(req.user.id, req.params.id, req.body);
        res.json(updatedItem);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Display items in watch list
router.get('/', async (req, res) => {
    try {
        const items = await WatchListService.getItems(req.user.id);
        res.json(items);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;