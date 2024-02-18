require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// Blockchain-related imports (Assuming Ethereum-based interactions)
const Web3 = require('web3');

const app = express();
const userRoutes = require('./Routes/userRoutes');
const errorMiddleware = require('./Middleware/errorMiddleware');

// Firebase Admin SDK initialization for centralized data management
const firebaseAdminConfig = {
  // Your Firebase admin configuration
};
initializeApp(firebaseAdminConfig);

// Web3 initialization for Ethereum blockchain interactions
const web3 = new Web3(process.env.BLOCKCHAIN_PROVIDER_URL);

// Middleware
app.use(cors());
app.use(helmet());
app.use(express.json());

// Apply rate limiting to all requests
app.use(rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
}));

// Logging middleware for development environment
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Routes
app.use('/api/v1/users', userRoutes);

// Error handling middleware
app.use(errorMiddleware);

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server started on port ${PORT}`);
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  console.info('SIGTERM signal received. Closing server.');
  server.close(() => {
    console.log('Http server closed.');
    // Additional cleanup if necessary
  });
});
