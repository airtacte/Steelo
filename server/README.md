# Steelo Backend Server Documentation

This document focuses on the Steelo backend server, detailing its setup, functionalities, and how it supports the Steelo mobile dApp.

## Server Setup

Ensure Node.js and Firebase CLI are installed. Set up environment variables as described in the main documentation. For server-specific variables, refer to `.env.example` in the server directory.

## Running the Server

Navigate to the `server` directory:

```
cd server
npm install
npm start
```

The server runs on `http://localhost:3000` by default. Adjust `PORT` in `.env` for different environments.

## API Endpoints

Endpoints for user management, community engagement, and digital asset transactions are documented in `api_documentation.md`. Includes routes for VILLAGE, GALLERY, MOSAIC, PROFILE, and BAZAAR features.

## Architecture

Built on Express.js, integrating with Firebase for data management and Web3 for blockchain interactions. Structured around MVC pattern to ensure scalability and maintainability.

### Middleware

Includes CORS, helmet for security, express-rate-limit for throttling, and morgan for logging in development mode. Custom middleware handles authentication and error responses.

## Security Measures

Describes CORS setup, helmet configurations, and rate limiting details. Ensure HTTPS in production and manage secrets securely.

## Data Management

Utilizes Firebase Firestore for centralized data storage, detailed in `data_model.md`. Web3 integration enables Ethereum transactions, with configurations outlined in `blockchain_integration.md`.

## Error Handling

Central error handling middleware captures and logs server errors, ensuring graceful API response. Details in `error_handling.md`.

## Contributing

Follows the contribution guidelines in the project's main documentation. For server-specific contributions, refer to `contributing_server.md`.

## Updates & Migration

Instructions for updating dependencies and migrating database schemas or blockchain contracts as the project evolves.