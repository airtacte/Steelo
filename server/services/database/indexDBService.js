// Import Firebase and MongoDB libraries
const firebase = require('firebase');
const MongoClient = require('mongodb').MongoClient;

class DatabaseService {
  constructor(firebaseConfig, mongoDbUrl, dbName, collectionName) {
    // Initialize Firebase
    if (!firebase.apps.length) {
      firebase.initializeApp(firebaseConfig);
    }
    this.firestore = firebase.firestore();

    // Initialize MongoDB
    this.mongoClient = new MongoClient(mongoDbUrl, { useUnifiedTopology: true });
    this.mongoDbName = dbName;
    this.collectionName = collectionName;
  }

  // Add or update data in Firestore and MongoDB
  async putData(data) {
    // Firestore
    await this.firestore.collection(this.collectionName).doc(data.id).set(data);

    // MongoDB
    const client = await this.mongoClient.connect();
    const collection = client.db(this.mongoDbName).collection(this.collectionName);
    await collection.updateOne({ id: data.id }, { $set: data }, { upsert: true });
    client.close();
  }

  // Retrieve data by ID from Firestore
  async getData(id) {
    // Firestore
    const doc = await this.firestore.collection(this.collectionName).doc(id).get();
    return doc.exists ? doc.data() : null;
  }

  // Delete data by ID from Firestore and MongoDB
  async deleteData(id) {
    // Firestore
    await this.firestore.collection(this.collectionName).doc(id).delete();

    // MongoDB
    const client = await this.mongoClient.connect();
    const collection = client.db(this.mongoDbName).collection(this.collectionName);
    await collection.deleteOne({ id: id });
    client.close();
  }
}

// Example usage
// const firebaseConfig = { /* your Firebase config */ };
// const mongoDbUrl = 'mongodb://localhost:27017';
// const dbName = 'SteeloDB';
// const collectionName = 'users';
// const databaseService = new DatabaseService(firebaseConfig, mongoDbUrl, dbName, collectionName);
// await databaseService.putData({ id: '123', name: 'John Doe' });