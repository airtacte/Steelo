const express = require('express');
const router = express.Router();
const listingController = require('../controllers/listingController');

router.post('/listings', listingController.createListing);
router.get('/listings', listingController.getListings);
router.put('/listings/:listingId', listingController.updateListing);
router.delete('/listings/:listingId', listingController.deleteListing);
router.get('/all-listings', listingController.getAllListings);

module.exports = router;