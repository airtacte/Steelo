const express = require('express');
const router = express.Router();
const watchListController = require('../../controllers/bazaar/userExperience/watchListController');

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user) {
      return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};
  
  // Middleware for input validation
  const validateInput = (req, res, next) => {
    // Add your input validation logic here
    next();
};

// Add item to watch list
router.post('/watchlist', authorize, validateInput, watchListController.addItem);

// Remove item from watch list
router.delete('/watchlist/:id', authorize, watchListController.removeItem);

// Update item in watch list
router.put('/watchlist/:id', authorize, validateInput, watchListController.updateItem);

// Display items in watch list
router.get('/watchlist', authorize, watchListController.displayItems);

module.exports = router;