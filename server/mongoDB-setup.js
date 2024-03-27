const { MongoClient } = require('mongodb');
require('dotenv').config();

const connectionString = process.env.MONGODB_CONNECTION_STRING;
const client = new MongoClient(connectionString);

async function run() {
  try {
    await client.connect();
    console.log("Connected to MongoDB Atlas");
    // Proceed with database operations here...
  } finally {
    await client.close();
  }
}

run().catch(console.dir);