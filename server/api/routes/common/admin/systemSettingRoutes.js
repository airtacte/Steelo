const express = require('express');
const systemSettingController = require('../../controllers/common/admin/systemSettingController');
const router = express.Router();

// Update system settings
router.put('/common/:id/systemSetting', systemSettingController.updateSystemSettings);

module.exports = router;