const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Village {
    constructor(data) {
      this.id = data.id;
      this.buyPrice = data.buyPrice;
      this.royaltiesCollected = data.royaltiesCollected;
      this.culture = data.culture;
      this.buyDate = data.buyDate;
      this.genre = data.genre;
      this.investorID = data.investorID;
      this.purchaseOrigin = data.purchaseOrigin;
      this.steezID = data.steezID;
      this.type = data.type;
      this.villageID = data.villageID;
    }

    validate() {
      if (!this.id || !this.buyPrice || !this.royaltiesCollected || !this.culture || !this.buyDate || !this.genre || !this.investorID || !this.purchaseOrigin || !this.steezID || !this.type || !this.villageID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('village').doc(id).get();
      if (!doc.exists) {
        throw new Error('Village not found');
      }
      return new Village({ id: doc.id, ...doc.data() });
    }

    static async fetchByInvestorID(investorID) {
      if (!investorID) {
        throw new Error('Missing investorID');
      }
      const snapshot = await db.collection('village').where('investorID', '==', investorID).get();
      if (snapshot.empty) {
        throw new Error('No matching villages found');
      }
      return snapshot.docs.map(doc => new Village({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('village').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('village').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('village').doc(this.id).delete();
    }
}

module.exports = Village;