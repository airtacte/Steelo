const express = require('express');
const router = express.Router();
const { displaySteez } = require('../../controllers/gallery/steez/steezDisplayController');

router.get('/:steezId', displaySteez);

module.exports = router;