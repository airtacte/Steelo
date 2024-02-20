const db = require('../../../firebase-config');

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
  
    static async fetchById(id) {
      const doc = await db.collection('collections').doc(id).get();
      if (!doc.exists) {
        throw new Error('Collection not found');
      }
      return new Collection({ id: doc.id, ...doc.data() });
    }
  
    async save() {
      await db.collection('collections').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      await db.collection('collections').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('collections').doc(this.id).delete();
    }
}

module.exports = Collection;  