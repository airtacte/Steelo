const express = require('express');
const router = express.Router();
const creditUpdateController = require('../../controllers/mosaic/credits/creditUpdateController');

router.put('/update', creditUpdateController.updateCredits);

module.exports = router;