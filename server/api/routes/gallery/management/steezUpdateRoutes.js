const express = require('express');
const router = express.Router();
const { updateSteez } = require('../../controllers/gallery/management/steezUpdateController');

router.put('/updateSteez', updateSteez);

module.exports = router;