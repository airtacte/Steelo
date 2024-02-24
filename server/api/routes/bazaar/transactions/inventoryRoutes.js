const express = require('express');
const { listInventoryItems, addInventoryItem, updateInventoryItem, deleteInventoryItem } = require('../../controllers/bazaar/transactions/inventoryController');
const router = express.Router();

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

router.get('/:userId/items', authorize, listInventoryItems);
router.post('/:userId/item', authorize, validateInput, addInventoryItem);
router.put('/item/:itemId', authorize, validateInput, updateInventoryItem);
router.delete('/item/:itemId', authorize, deleteInventoryItem);

module.exports = router;