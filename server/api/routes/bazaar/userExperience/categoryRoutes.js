const express = require('express');
const router = express.Router();
const categoryController = require('../../controllers/bazaar/userExperience/categoryController');

router.get('/', categoryController.getCategories);
router.post('/', categoryController.addCategory);

module.exports = router;