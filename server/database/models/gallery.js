const db = require('../../../firebase-config');

class Gallery {
    constructor(id, royaltiesCollected, purchaseDate, galleryID, investorID, steezID, returnOnInvestment, transactionID) {
      this.id = id;
      this.royaltiesCollected = royaltiesCollected;
      this.purchaseDate = purchaseDate;
      this.galleryID = galleryID;
      this.investorID = investorID;
      this.steezID = steezID;
      this.returnOnInvestment = returnOnInvestment;
      this.transactionID = transactionID;
    }
  
    async save() {
      await db.collection('galleries').doc(this.id).set({
        royaltiesCollected: this.royaltiesCollected,
        purchaseDate: this.purchaseDate,
        galleryID: this.galleryID,
        investorID: this.investorID,
        steezID: this.steezID,
        returnOnInvestment: this.returnOnInvestment,
        transactionID: this.transactionID,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('galleries').doc(id).get();
      if (!doc.exists) {
        throw new Error('Gallery not found');
      }
      return new Gallery(doc.id, doc.data());
    }
  
    async update(data) {
        await db.collection('galleries').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('galleries').doc(this.id).delete();
    }
}

module.exports = Gallery;  