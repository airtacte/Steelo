const express = require('express');
const router = express.Router();
const listingController = require('../controllers/listingController');

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

router.post('/listings', authorize, validateInput, listingController.createListing);
router.get('/listings', authorize, listingController.getListings);
router.put('/listings/:listingId', authorize, validateInput, listingController.updateListing);
router.delete('/listings/:listingId', authorize, listingController.deleteListing);
router.get('/all-listings', authorize,  listingController.getAllListings);

module.exports = router;