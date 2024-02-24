const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const provider = new HDWalletProvider(
  process.env.MNEMONIC,
  process.env.POLYGON_ZKEVM_TESTNET_RPC_URL
);
const web3 = new Web3(provider);

exports.addOrder = async (req, res) => {
  try {
    const contractAddress = 'your-contract-address';
    const contractABI = []; // your contract ABI

    const contract = new web3.eth.Contract(contractABI, contractAddress);
    await contract.methods.addOrder(req.body).send({ from: req.user.address });

    res.status(201).json({ message: 'Order added successfully.' });
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.removeOrder = async (req, res) => {
  try {
    const contractAddress = 'your-contract-address';
    const contractABI = []; // your contract ABI

    const contract = new web3.eth.Contract(contractABI, contractAddress);
    await contract.methods.removeOrder(req.params.orderId).send({ from: req.user.address });

    res.status(200).json({ message: 'Order removed successfully.' });
  } catch (error) {
    res.status(500).send(error.message);
  }
};