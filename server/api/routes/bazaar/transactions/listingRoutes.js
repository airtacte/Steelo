const express = require('express');
const { createListing, deleteListing } = require('../../controllers/bazaar/transactions/listingController');
const router = express.Router();

exports.createListing = async (req, res) => {
    try {
        const listing = await ListingsService.createListing(req.body);
        res.status(201).json(listing);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.getListings = async (req, res) => {
    try {
        const listings = await ListingsService.fetchAllListings();
        res.json(listings);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.updateListing = async (req, res) => {
    // Code to update details of a listing
};

exports.deleteListing = async (req, res) => {
    // Code to delete a listing
};

exports.getAllListings = async (req, res) => {
    // Code to retrieve all listings in the marketplace
};

module.exports = router;