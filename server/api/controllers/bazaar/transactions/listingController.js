const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const provider = new HDWalletProvider(
    process.env.MNEMONIC,
    process.env.POLYGON_ZKEVM_TESTNET_RPC_URL
);
const web3 = new Web3(provider);

exports.createListing = async (req, res) => {
    try {
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.createListing(req.body).send({ from: req.user.address });

        res.status(201).json({ message: 'Listing created successfully.' });
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.getListings = async (req, res) => {
    try {
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        const listings = await contract.methods.getListings().call();

        res.json(listings);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.updateListing = async (req, res) => {
    try {
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.updateListing(req.params.listingId, req.body).send({ from: req.user.address });

        res.status(200).json({ message: 'Listing updated successfully.' });
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.deleteListing = async (req, res) => {
    try {
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.deleteListing(req.params.listingId).send({ from: req.user.address });

        res.status(200).json({ message: 'Listing deleted successfully.' });
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.getAllListings = async (req, res) => {
    try {
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        const listings = await contract.methods.getAllListings().call();

        res.json(listings);
    } catch (error) {
        res.status(500).send(error.message);
    }
};