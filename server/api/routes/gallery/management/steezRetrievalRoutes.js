const express = require('express');
const router = express.Router();
const { retrieveSteez } = require('../../controllers/gallery/management/steezRetrievalController');

router.get('/retrieveSteez', retrieveSteez);

module.exports = router;