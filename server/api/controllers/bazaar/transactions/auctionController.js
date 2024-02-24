const AuctionsService = require('../services/auctionsService');
const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const provider = new HDWalletProvider(
    process.env.MNEMONIC,
    process.env.POLYGON_ZKEVM_TESTNET_RPC_URL
);
const web3 = new Web3(provider);

exports.initiateAuction = async (req, res) => {
    try {
        const auction = await AuctionsService.initiateAuction(req.body);
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.initiateAuction(auction.id, auction.floorPrice, auction.bidIncrement, auction.slots).send({ from: req.user.address });

        res.status(201).json(auction);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.placeBid = async (req, res) => {
    try {
        const auction = await AuctionsService.placeBid(req.params.auctionId, req.body);
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.placeBid(auction.id).send({ from: req.user.address, value: req.body.bidAmount });

        res.json(auction);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.autoBidToggle = async (req, res) => {
    try {
        const auction = await AuctionsService.autoBidToggle(req.params.auctionId, req.user.id);
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.autoBidToggle(auction.id).send({ from: req.user.address });

        res.json(auction);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.fetchLeaderboard = async (req, res) => {
    try {
        const leaderboard = await AuctionsService.fetchLeaderboard(req.params.auctionId);
        res.json(leaderboard);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.endAuction = async (req, res) => {
    try {
        const auction = await AuctionsService.endAuction(req.params.auctionId);
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        const result = await contract.methods.endAuction(auction.id).send({ from: req.user.address });

        res.json(result);
    } catch (error) {
        res.status(500).send(error.message);
    }
};