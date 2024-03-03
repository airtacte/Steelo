const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Steelo {
    constructor(data) {
      this.id = data.id;
      this.mintAmount = data.mintAmount;
      this.marketCap = data.marketCap;
      this.burnAmount = data.burnAmount;
      this.isDeflationary = data.isDeflationary;
      this.burnRate = data.burnRate;
      this.tokenSupply = data.tokenSupply;
      this.lastMint = data.lastMint;
      this.currentPrice = data.currentPrice;
      this.steeloID = data.steeloID;
      this.transactionCount = data.transactionCount;
      this.lastBurn = data.lastBurn;
      this.mintRate = data.mintRate;
    }

    validate() {
      if (!this.id || !this.mintAmount || !this.marketCap || !this.burnAmount || this.isDeflationary === undefined || !this.burnRate || !this.tokenSupply || !this.lastMint || !this.currentPrice || !this.steeloID || !this.transactionCount || !this.lastBurn || !this.mintRate) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('steelos').doc(id).get();
      if (!doc.exists) {
        throw new Error('Steelo not found');
      }
      return new Steelo({ id: doc.id, ...doc.data() });
    }

    static async fetchBySteeloID(steeloID) {
      if (!steeloID) {
        throw new Error('Missing steeloID');
      }
      const snapshot = await db.collection('steelos').where('steeloID', '==', steeloID).get();
      if (snapshot.empty) {
        throw new Error('No matching steelos found');
      }
      return snapshot.docs.map(doc => new Steelo({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('steelos').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('steelos').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('steelos').doc(this.id).delete();
    }
}

module.exports = Steelo;