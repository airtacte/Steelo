const db = require('../../../firebase-config');

class Trade {
    constructor(data) {
      this.id = data.id;
      this.buyPrice = data.buyPrice;
      this.profileID = data.profileID;
      this.buyDate = data.buyDate;
      this.steezID = data.steezID;
      this.tradeID = data.tradeID;
      this.tradeType = data.tradeType;
      this.status = data.status;
    }

    validate() {
      if (!this.id || !this.buyPrice || !this.profileID || !this.buyDate || !this.steezID || !this.tradeID || !this.tradeType || !this.status) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('trade').doc(id).get();
      if (!doc.exists) {
        throw new Error('Trade not found');
      }
      return new Trade({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('trade').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching trades found');
      }
      return snapshot.docs.map(doc => new Trade({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('trade').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('trade').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('trade').doc(this.id).delete();
    }
}

module.exports = Trade;