const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');
const serviceAccount = require('../config/firebase-service-account.json');
const Web3 = require('web3');
const ERC725 = require('@erc725/erc725.js');
const LSP4DigitalAssetMetadata = require('@erc725/erc725.js/schemas/LSP4DigitalAssetMetadata.json');
const ethers = require('ethers');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Ethereum Blockchain Setup
const provider = new ethers.providers.JsonRpcProvider(process.env.BLOCKCHAIN_RPC_URL);
const web3 = new Web3(process.env.BLOCKCHAIN_RPC_URL);
const lsp4Schema = LSP4DigitalAssetMetadata;

// Middleware to authenticate and authorize users
const authenticate = async (req, res, next) => {
  try {
    const token = req.headers.authorization.split(' ')[1]; // Bearer <token>
    const decodedToken = jwt.verify(token, process.env.JWT_SECRET);

    // Validate token expiration and user existence in Firebase
    const userSnapshot = await admin.firestore().collection('users').doc(decodedToken.uid).get();
    if (!userSnapshot.exists) {
      throw new Error('User does not exist.');
    }

    // Additional blockchain validation for user
    const userBlockchainAddress = userSnapshot.data().blockchainAddress;
    const erc725 = new ERC725(lsp4Schema, userBlockchainAddress, provider, { ipfsGateway: process.env.IPFS_GATEWAY });

    // Fetch user data from blockchain
    const userDataOnChain = await erc725.getData('LSP3Profile');
    if (!userDataOnChain) {
      throw new Error('Unable to retrieve user data from the blockchain.');
    }

    // Optional: Validate specific roles or permissions
    // This could involve checking token claims or on-chain permissions for advanced use cases

    // Attach user information to request object
    req.user = { uid: decodedToken.uid, blockchainAddress: userBlockchainAddress, ...userSnapshot.data() };

    next(); // Proceed to next middleware or route handler
  } catch (error) {
    console.error('Authentication Middleware Error:', error.message);
    return res.status(401).json({ error: 'Authentication failed' });
  }
};

module.exports = authenticate;