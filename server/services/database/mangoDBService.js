const { MongoClient } = require("mongodb");
require("dotenv").config();

class MongoDBService {
  constructor() {
    this.client = new MongoClient(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    this.database = this.client.db(process.env.MONGODB_DB_NAME);
  }

  async connect() {
    if (!this.client.isConnected()) {
      await this.client.connect();
    }
  }

  async disconnect() {
    await this.client.close();
  }

  // Add document to a collection
  async addDocument(collectionName, documentData) {
    await this.connect();
    const collection = this.database.collection(collectionName);
    const result = await collection.insertOne(documentData);
    await this.disconnect();
    return { id: result.insertedId, ...documentData };
  }

  // Get a document by ID
  async getDocumentById(collectionName, documentId) {
    await this.connect();
    const collection = this.database.collection(collectionName);
    const document = await collection.findOne({ _id: documentId });
    await this.disconnect();
    if (!document) {
      console.log("Document not found!");
      return null;
    }
    return document;
  }

  // Update a document
  async updateDocument(collectionName, documentId, documentData) {
    await this.connect();
    const collection = this.database.collection(collectionName);
    const result = await collection.updateOne(
      { _id: documentId },
      { $set: documentData }
    );
    await this.disconnect();
    return result.modifiedCount === 1
      ? { id: documentId, ...documentData }
      : null;
  }

  // Delete a document
  async deleteDocument(collectionName, documentId) {
    await this.connect();
    const collection = this.database.collection(collectionName);
    const result = await collection.deleteOne({ _id: documentId });
    await this.disconnect();
    return result.deletedCount === 1;
  }
}

module.exports = new MongoDBService();