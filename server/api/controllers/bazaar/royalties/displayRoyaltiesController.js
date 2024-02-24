const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const provider = new HDWalletProvider(
  process.env.MNEMONIC,
  process.env.POLYGON_ZKEVM_TESTNET_RPC_URL
);
const web3 = new Web3(provider);

exports.displayRoyalties = async (req, res) => {
  try {
    const db = getFirestore();
    const royaltiesSnapshot = await db.collection('royalties').where('creatorId', '==', req.params.creatorId).get();
    
    if (royaltiesSnapshot.empty) {
      return res.status(404).send('No royalties found for the specified creator.');
    }
    
    let royalties = [];
    royaltiesSnapshot.forEach(doc => {
      royalties.push({ id: doc.id, ...doc.data() });
    });

    // Placeholder for the contract address and ABI
    const contractAddress = 'your-contract-address';
    const contractABI = []; // your contract ABI

    const contract = new web3.eth.Contract(contractABI, contractAddress);

    // Placeholder for the creator's address
    const creatorAddress = 'creator-address';

    // Fetch the creator's royalties from the smart contract
    const creatorRoyalties = await contract.methods.getRoyalties(creatorAddress).call();

    // Add the creator's royalties from the smart contract to the royalties array
    royalties.push({
      id: 'from-smart-contract',
      creatorId: req.params.creatorId,
      royalties: creatorRoyalties
    });
    
    res.status(200).json(royalties);
  } catch (error) {
    console.error('Error displaying royalties:', error);
    res.status(500).send('Error retrieving royalty information.');
  }
};