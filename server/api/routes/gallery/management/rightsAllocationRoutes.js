const express = require('express');
const router = express.Router();
const rightsAllocationController = require('../../controllers/gallery/management/rightsAllocationController');

router.post('/allocateRights', rightsAllocationController.allocateRights);

module.exports = router;