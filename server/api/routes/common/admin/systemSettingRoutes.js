const express = require('express');
const systemSettingController = require('../../controllers/common/admin/systemSettingController');
const router = express.Router();

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user) {
      return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};
  
  // Middleware for input validation
  const validateInput = (req, res, next) => {
    // Add your input validation logic here
    next();
};

// Update system settings
router.put('/common/:id/systemSetting', authorize, validateInput, systemSettingController.updateSystemSettings);

module.exports = router;