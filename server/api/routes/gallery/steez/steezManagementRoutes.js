const express = require('express');
const router = express.Router();
const { createSteez, updateSteez, deleteSteez } = require('../../controllers/gallery/steez/steezManagementController');

router.post('/', createSteez);
router.put('/:steezId', updateSteez);
router.delete('/:steezId', deleteSteez);

module.exports = router;