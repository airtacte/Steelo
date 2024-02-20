const { getFirestore } = require('firebase-admin/firestore');

// Initialize Firestore
const db = getFirestore();

class FirestoreService {
  constructor() {
    this.db = db;
  }

  // Add document to a collection
  async addDocument(collectionName, documentData) {
    try {
      const docRef = await this.db.collection(collectionName).add(documentData);
      return { id: docRef.id, ...documentData };
    } catch (error) {
      console.error(`Error adding document to ${collectionName}:`, error);
      throw new Error('Failed to add document.');
    }
  }

  // Get a document by ID
  async getDocumentById(collectionName, documentId) {
    try {
      const doc = await this.db.collection(collectionName).doc(documentId).get();
      if (!doc.exists) {
        console.log('Document not found!');
        return null;
      }
      return { id: doc.id, ...doc.data() };
    } catch (error) {
      console.error(`Error getting document from ${collectionName}:`, error);
      throw new Error('Failed to get document.');
    }
  }

  // Update a document
  async updateDocument(collectionName, documentId, documentData) {
    try {
      await this.db.collection(collectionName).doc(documentId).update(documentData);
      return { id: documentId, ...documentData };
    } catch (error) {
      console.error(`Error updating document in ${collectionName}:`, error);
      throw new Error('Failed to update document.');
    }
  }

  // Delete a document
  async deleteDocument(collectionName, documentId) {
    try {
      await this.db.collection(collectionName).doc(documentId).delete();
      return { message: 'Document successfully deleted' };
    } catch (error) {
      console.error(`Error deleting document from ${collectionName}:`, error);
      throw new Error('Failed to delete document.');
    }
  }

  // Query documents with conditions
  async queryDocuments(collectionName, queryConditions) {
    try {
      let query = this.db.collection(collectionName);
      queryConditions.forEach(condition => {
        query = query.where(...condition);
      });
      const snapshot = await query.get();
      if (snapshot.empty) {
        console.log('No matching documents.');
        return [];
      }
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      console.error(`Error querying documents from ${collectionName}:`, error);
      throw new Error('Failed to query documents.');
    }
  }
}

module.exports = new FirestoreService();