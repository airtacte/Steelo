const { getFirestore } = require('firebase-admin/firestore');
const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const provider = new HDWalletProvider(
  process.env.MNEMONIC,
  process.env.POLYGON_ZKEVM_TESTNET_RPC_URL
);

const web3 = new Web3(provider);

exports.listInventoryItems = async (req, res) => {
  try {
    const db = getFirestore();
    const inventorySnapshot = await db.collection('inventory').where('userId', '==', req.params.userId).get();
    if (inventorySnapshot.empty) {
      return res.status(404).send('No inventory items found.');
    }
    let items = [];
    inventorySnapshot.forEach(doc => items.push({ id: doc.id, ...doc.data() }));
    res.status(200).json(items);
  } catch (error) {
    console.error('Error listing inventory items:', error);
    res.status(500).send('Failed to list inventory items.');
  }
};

exports.addInventoryItem = async (req, res) => {
  try {
    const db = getFirestore();
    const docRef = await db.collection('inventory').add({
      ...req.body, // Assuming body contains all necessary item details
      userId: req.params.userId, // User ID should be validated or extracted from session
      createdAt: new Date()
    });

    const contractAddress = 'your-contract-address';
    const contractABI = []; // your contract ABI

    const contract = new web3.eth.Contract(contractABI, contractAddress);
    await contract.methods.mintNFT(req.params.userId, docRef.id).send({ from: req.user.address });

    res.status(201).send(`Inventory item added with ID: ${docRef.id}`);
  } catch (error) {
    console.error('Error adding inventory item:', error);
    res.status(500).send('Failed to add inventory item.');
  }
};

exports.updateInventoryItem = async (req, res) => {
  try {
    const db = getFirestore();
    const { itemId } = req.params;
    const itemRef = db.collection('inventory').doc(itemId);
    await itemRef.update({...req.body});

    const contractAddress = 'your-contract-address';
    const contractABI = []; // your contract ABI

    const contract = new web3.eth.Contract(contractABI, contractAddress);
    await contract.methods.updateNFT(req.params.userId, itemId, req.body).send({ from: req.user.address });

    res.status(200).send(`Inventory item ${itemId} updated successfully.`);
  } catch (error) {
    console.error('Error updating inventory item:', error);
    res.status(500).send('Failed to update inventory item.');
  }
};

exports.deleteInventoryItem = async (req, res) => {
  try {
    const db = getFirestore();
    await db.collection('inventory').doc(req.params.itemId).delete();

    const contractAddress = 'your-contract-address';
    const contractABI = []; // your contract ABI

    const contract = new web3.eth.Contract(contractABI, contractAddress);
    await contract.methods.burnNFT(req.params.userId, req.params.itemId).send({ from: req.user.address });

    res.status(200).send(`Inventory item ${req.params.itemId} deleted successfully.`);
  } catch (error) {
    console.error('Error deleting inventory item:', error);
    res.status(500).send('Failed to delete inventory item.');
  }
};