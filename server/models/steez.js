const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Steez {
    constructor(data) {
      this.id = data.id;
      this.steezAmount = data.steezAmount;
      this.royaltiesGenerated = data.royaltiesGenerated;
      this.hasSoldInvestment = data.hasSoldInvestment;
      this.preOrderPrice = data.preOrderPrice;
      this.ownerHistory = data.ownerHistory;
      this.creatorID = data.creatorID;
      this.currentPrice = data.currentPrice;
      this.sellPrice = data.sellPrice;
      this.sellDate = data.sellDate;
      this.transactionCount = data.transactionCount;
    }

    validate() {
      if (!this.id || !this.steezAmount || !this.royaltiesGenerated || this.hasSoldInvestment === undefined || !this.preOrderPrice || !this.ownerHistory || !this.creatorID || !this.currentPrice || !this.sellPrice || !this.sellDate || !this.transactionCount) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('steez').doc(id).get();
      if (!doc.exists) {
        throw new Error('Steez not found');
      }
      return new Steez({ id: doc.id, ...doc.data() });
    }

    static async fetchByCreatorID(creatorID) {
      if (!creatorID) {
        throw new Error('Missing creatorID');
      }
      const snapshot = await db.collection('steez').where('creatorID', '==', creatorID).get();
      if (snapshot.empty) {
        throw new Error('No matching steez found');
      }
      return snapshot.docs.map(doc => new Steez({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('steez').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('steez').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('steez').doc(this.id).delete();
    }
}

module.exports = Steez;