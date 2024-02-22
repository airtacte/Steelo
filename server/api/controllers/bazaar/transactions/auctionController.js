const AuctionsService = require('../services/auctionsService');

exports.startAuction = async (req, res) => {
    try {
        const auction = await AuctionsService.startNewAuction(req.body);
        res.status(201).json(auction);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.placeBid = async (req, res) => {
    try {
        const auction = await AuctionsService.placeBid(req.params.auctionId, req.body);
        res.json(auction);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.endAuction = async (req, res) => {
    res.send('Auction end functionality here.');
  };