const express = require('express');
const analyticsController = require('../../controllers/bazaar/analyticsController');
const { auth } = require('firebase-admin');
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

// Route to get analytics data for a specific asset
router.get('/analytics/:assetId', authorize, analyticsController.getAssetAnalytics);

module.exports = router;