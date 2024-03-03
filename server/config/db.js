const { MongoClient } = require('mongodb');

const uri = process.env.MONGODB_URI;
let db = null;

async function connectDB() {
  if (db) return db;
  const client = new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
  await client.connect();
  db = client.db(process.env.MONGODB_DB_NAME);
  console.log('Connected to MongoDB');
  return db;
}

module.exports = connectDB;