require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const Web3 = require('web3');

const app = express();
const userRoutes = require('./Routes/userRoutes');
const errorMiddleware = require('./Middleware/errorMiddleware');

// Improved Firebase Admin SDK initialization
initializeApp(); // Assuming credentials are securely managed via environment variables

// Web3 initialization with error handling for Ethereum blockchain interactions
const web3 = new Web3(process.env.BLOCKCHAIN_PROVIDER_URL || 'http://localhost:8545');

// Middleware configurations
app.use(cors());
app.use(helmet());
app.use(express.json());

// Enhanced rate limiting for more granular control
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// Apply the rate limiter to all requests
app.use(apiLimiter);

// Logging middleware for development environment
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// API Routes
app.use('/api/v1/users', userRoutes);

// Centralized Error Handling
app.use(errorMiddleware);

// Health Check Endpoint
app.get('/health', (req, res) => res.status(200).send('OK'));

// Start server with improved logging and error handling
const server = app.listen(process.env.PORT || 3000, () => {
    console.log(`Server started on port ${process.env.PORT || 3000}`);
});

// Improved graceful shutdown handling
process.on('SIGTERM', () => {
  console.info('SIGTERM signal received. Closing server.');
  server.close(() => {
    console.log('Http server closed.');
    // Ensure all connections like database, blockchain are properly closed here
  });
});