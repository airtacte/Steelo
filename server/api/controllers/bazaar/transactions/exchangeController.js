const UniswapService = require('../services/uniswapService');
const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const provider = new HDWalletProvider(
  process.env.MNEMONIC,
  process.env.POLYGON_ZKEVM_TESTNET_RPC_URL
);
const web3 = new Web3(provider);

exports.tradeAssets = async (req, res) => {
  try {
    const trade = await UniswapService.tradeAssets(req.body);
    const contractAddress = 'your-contract-address';
    const contractABI = []; // your contract ABI

    const contract = new web3.eth.Contract(contractABI, contractAddress);
    await contract.methods.tradeAssets(trade.id, trade.asset1, trade.asset2, trade.amount).send({ from: req.user.address });

    res.status(201).json(trade);
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.getExchangeRates = async (req, res) => {
  try {
    const rates = await UniswapService.getExchangeRates(req.body);
    res.json(rates);
  } catch (error) {
    res.status(500).send(error.message);
  }
};