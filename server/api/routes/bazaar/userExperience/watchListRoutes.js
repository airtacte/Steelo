const express = require('express');
const router = express.Router();
const watchListController = require('../../controllers/bazaar/userExperience/watchListController');

// Add item to watch list
router.post('/watchlist', watchListController.addItem);

// Remove item from watch list
router.delete('/watchlist/:id', watchListController.removeItem);

// Update item in watch list
router.put('/watchlist/:id', watchListController.updateItem);

// Display items in watch list
router.get('/watchlist', watchListController.displayItems);

module.exports = router;