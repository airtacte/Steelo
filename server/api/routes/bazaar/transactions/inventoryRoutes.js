const express = require('express');
const { listInventoryItems, addInventoryItem, updateInventoryItem, deleteInventoryItem } = require('../../controllers/bazaar/transactions/inventoryController');
const router = express.Router();

router.get('/:userId/items', listInventoryItems);
router.post('/:userId/item', addInventoryItem);
router.put('/item/:itemId', updateInventoryItem);
router.delete('/item/:itemId', deleteInventoryItem);

module.exports = router;