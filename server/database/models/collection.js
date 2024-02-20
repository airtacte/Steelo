const db = require('../../../firebase-config');

class Collection {
    constructor(data) {
      this.id = data.id;
      this.salePrice = data.salePrice;
      this.collectID = data.collectID;
      this.isSold = data.isSold;
      this.collectionPrice = data.collectionPrice;
      this.saleDate = data.saleDate;
      this.returnOnInvestment = data.returnOnInvestment;
      this.collectionID = data.collectionID;
      this.collectionDate = data.collectionDate;
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