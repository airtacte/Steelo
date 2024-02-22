const express = require('express');
const router = express.Router();
const searchController = require('../../controllers/bazaar/userExperience/SearchController');

router.get('/', searchController.performSearch);

module.exports = router;