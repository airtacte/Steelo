const { MongoClient } = require('mongodb');
const functions = require('firebase-functions');

const uri = functions.config().mongodb.uri;
let db = null;

async function connectDB() {
  if (db) return db;
  const client = new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
  await client.connect();
  db = client.db(functions.config().mongodb.dbname);
  console.log('Connected to MongoDB');
  return db;
}

module.exports = connectDB;
