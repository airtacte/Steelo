const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Collection {
    constructor(data) {
      this.id = data.id;
      this.collectID = data.collectID;
      this.collectionDate = data.collectionDate;
      this.collectionID = data.collectionID;
      this.collectionPrice = data.collectionPrice;
      this.isSold = data.isSold;
      this.returnOnInvestment = data.returnOnInvestment;
      this.saleDate = data.saleDate;
      this.salePrice = data.salePrice;
      this.transactionID = data.transactionID;
    }
  
    validate() {
      if (!this.id || !this.collectID || !this.collectionDate || !this.collectionID || !this.collectionPrice) {
        throw new Error('Missing required fields');
      }
    }

    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('collections').doc(id).get();
      if (!doc.exists) {
        throw new Error('Collection not found');
      }
      return new Collection({ id: doc.id, ...doc.data() });
    }

    static async fetchByCollectID(collectID) {
      if (!collectID) {
        throw new Error('Missing collectID');
      }
      const snapshot = await db.collection('collections').where('collectID', '==', collectID).get();
      if (snapshot.empty) {
        throw new Error('No matching collections found');
      }
      return snapshot.docs.map(doc => new Collection({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('collections').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('collections').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('collections').doc(this.id).delete();
    }
}

module.exports = Collection;  