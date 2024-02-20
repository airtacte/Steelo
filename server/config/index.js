const dotenv = require('dotenv');
dotenv.config();

module.exports = {
  // Server settings
  server: {
    port: process.env.PORT || 3000,
  },

  // Blockchain network settings
  blockchain: {
    polygonZkEvmTestnetRpcUrl: process.env.POLYGON_ZKEVM_TESTNET_RPC_URL,
    polygonZkEvmTestnetChainId: process.env.POLYGON_ZKEVM_TESTNET_CHAIN_ID || '80001', // Polygon Mumbai Testnet as default
    mnemonic: process.env.MNEMONIC,
  },

  // MongoDB Configuration
  mongodb: {
    uri: process.env.MONGODB_URI,
    dbName: process.env.MONGODB_DB_NAME,
  },

  // Firebase configuration for NoSQL database
  firebase: {
    apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
    authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
    projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
    storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
    appId: process.env.REACT_APP_FIREBASE_APP_ID,
    measurementId: process.env.REACT_APP_FIREBASE_MEASUREMENT_ID,
  },

  // IPFS settings for decentralized storage
  ipfs: {
    host: process.env.IPFS_HOST || 'ipfs.infura.io',
    port: process.env.IPFS_PORT || 5001,
    protocol: process.env.IPFS_PROTOCOL || 'https',
  },

  // API keys for external services
  externalApis: {
    ethGasStationApiKey: process.env.ETH_GAS_STATION_API_KEY, // For estimating gas prices on Ethereum
  },

  // Wallet addresses for the ecosystem
  wallets: {
    liquidityProvidersTestWallet: process.env.LIQUIDITY_PROVIDERS_TESTWALLET,
    ecosystemProvidersTestWallet: process.env.ECOSYSTEM_PROVIDERS_TESTWALLET,
    foundersTestWallet: process.env.FOUNDERS_TESTWALLET,
    earlyInvestorsTestWallet: process.env.EARLY_INVESTORS_TESTWALLET,
    communityTestWallet: process.env.COMMUNITY_TESTWALLET,
    steeloTestWallet: process.env.STEELO_TESTWALLET,
  },

  // Security settings
  security: {
    jwtSecret: process.env.JWT_SECRET,
  },

  // Security settings
  security: {
    jwtSecret: process.env.JWT_SECRET,
    encryptionKey: process.env.ENCRYPTION_KEY,
  },

  // Other configurations as needed
};