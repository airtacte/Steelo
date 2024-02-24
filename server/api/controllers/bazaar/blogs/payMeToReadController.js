const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const provider = new HDWalletProvider(
  process.env.MNEMONIC,
  process.env.POLYGON_ZKEVM_TESTNET_RPC_URL
);
const web3 = new Web3(provider);

exports.payMeToRead = async (req, res) => {
    try {
        // Placeholder for the contract address and ABI
        const contractAddress = 'your-contract-address';
        const contractABI = []; // your contract ABI

        const contract = new web3.eth.Contract(contractABI, contractAddress);

        // Placeholder for the user's address
        const userAddress = 'user-address';

        // Check if the user has paid
        const hasPaid = await contract.methods.hasPaid(userAddress).call();

        if (!hasPaid) {
            return res.status(403).send('You must pay to read this blog post');
        }

        const db = getFirestore();
        const doc = await db.collection('blogs').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).send('Blog not found');
        }

        // Fetch additional metrics data
        const metricsData = await db.collection('blogMetrics')
                                     .where('blogId', '==', req.params.id)
                                     .get();

        if (metricsData.empty) {
            return res.status(404).send('No metrics data found for the specified blog.');
        }

        let readingDuration = 0;
        let completionRate = 0;
        let pageVisits = 0;
        let steezInvestments = 0;

        metricsData.forEach(doc => {
            const data = doc.data();
            readingDuration += data.readingDuration || 0;
            completionRate += data.completionRate || 0;
            pageVisits += data.pageVisits || 0;
            steezInvestments += data.steezInvestments || 0;
        });

        res.status(200).json({
            message: 'Access granted to blog post',
            ...doc.data(),
            readingDuration,
            completionRate,
            pageVisits,
            steezInvestments
        });
    } catch (error) {
        res.status(500).send('Error retrieving blog');
    }
};