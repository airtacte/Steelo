import { ethers } from 'ethers';
import { ApolloClient, InMemoryCache } from '@apollo/client';
import { HttpLink } from 'apollo-link-http';
require('dotenv').config();

// Initialize ethers with a provider
const provider = new ethers.providers.JsonRpcProvider(process.env.POLYGON_ZKEVM_TESTNET_RPC_URL);

// Set up Apollo client for GraphQL interaction
const httpLink = new HttpLink({
  uri: 'https://api.lens.dev',
});

const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
});

// Export the configured client
export { client, provider };


/*
// Example usage in some component or service

import { client, provider } from '../blockchain/lensClient';

// Use the provider to interact with smart contracts
// Use the client to send GraphQL queries
*/