const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();
const { ChainlinkPriceFeed } = require('chainlink-price-feed');

const provider = new HDWalletProvider(
    process.env.MNEMONIC,
    process.env.POLYGON_ZKEVM_TESTNET_RPC_URL
);
const web3 = new Web3(provider);

const priceFeed = new ChainlinkPriceFeed('ETH', 'GBP');

exports.initiatePurchase = async (req, res) => {
    try {
        const { token, amount } = req.body;

        // Debit the customer using Stripe
        const charge = await stripe.charges.create({
            amount: amount,
            currency: 'gbp',
            description: 'Purchase description',
            source: token,
        });

        // Convert the amount to the relevant crypto
        const cryptoAmount = convertToCrypto(amount);

        // Transfer the crypto to the escrow smart contract
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.transferToEscrow(cryptoAmount).send({ from: req.user.address });

        res.status(201).json({ message: 'Purchase initiated successfully.' });
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.completePurchase = async (req, res) => {
    try {
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.completePurchase(req.params.purchaseId).send({ from: req.user.address });

        res.status(200).json({ message: 'Purchase completed successfully.' });
    } catch (error) {
        res.status(500).send(error.message);
    }
};

exports.cancelPurchase = async (req, res) => {
    try {
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);
        await contract.methods.cancelPurchase(req.params.purchaseId).send({ from: req.user.address });

        res.status(200).json({ message: 'Purchase cancelled successfully.' });
    } catch (error) {
        res.status(500).send(error.message);
    }
};

async function convertToCrypto(amount) {
    try {
      // Get the current exchange rate
      const exchangeRate = await priceFeed.getPrice();
  
      // Apply any custom fees
      const fee = 0.02; // 2% fee
      const amountAfterFee = amount - amount * fee;
  
      // Convert the amount to crypto
      const cryptoAmount = amountAfterFee / exchangeRate;
  
      return cryptoAmount;
    } catch (error) {
      console.error(error);
      return amount;
    }
  }