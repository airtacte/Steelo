const db = require('../../../firebase-config');

class Transaction {
    constructor(data) {
      this.id = data.id;
      this.buyPrice = data.buyPrice;
      this.buyerID = data.buyerID;
      this.buyAmount = data.buyAmount;
      this.sellerID = data.sellerID;
      this.buyDate = data.buyDate;
      this.steezID = data.steezID;
      this.type = data.type;
      this.transactionID = data.transactionID;
      this.status = data.status;
    }

    validate() {
      if (!this.id || !this.buyPrice || !this.buyerID || !this.buyAmount || !this.sellerID || !this.buyDate || !this.steezID || !this.type || !this.transactionID || !this.status) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('transaction').doc(id).get();
      if (!doc.exists) {
        throw new Error('Transaction not found');
      }
      return new Transaction({ id: doc.id, ...doc.data() });
    }

    static async fetchByBuyerID(buyerID) {
      if (!buyerID) {
        throw new Error('Missing buyerID');
      }
      const snapshot = await db.collection('transaction').where('buyerID', '==', buyerID).get();
      if (snapshot.empty) {
        throw new Error('No matching transactions found');
      }
      return snapshot.docs.map(doc => new Transaction({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('transaction').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('transaction').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('transaction').doc(this.id).delete();
    }
}

module.exports = Transaction;