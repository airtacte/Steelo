const express = require('express');
const { initiateAuction, placeBid, autoBidToggle, fetchLeaderboard, endAuction } = require('../../controllers/bazaar/transactions/auctionController');
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

// Auction Management
router.post('/initiateAuction', authorize, validateInput, protect, initiateAuction);
router.post('/placeBid', authorize, validateInput,protect, placeBid);
router.post('/autoBidToggle', authorize, validateInput, protect, autoBidToggle);
router.get('/fetchLeaderboard', authorize, protect, fetchLeaderboard);
router.post('/endAuction', authorize, validateInput, protect, endAuction);

module.exports = router;