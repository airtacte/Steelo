const db = require('../../../firebase-config');

class Gallery {
    constructor(data) {
      this.id = data.id;
      this.galleryID = data.galleryID;
      this.investorID = data.investorID;
      this.purchaseDate = data.purchaseDate;
      this.returnOnInvestment = data.returnOnInvestment;
      this.royaltiesCollected = data.royaltiesCollected;
      this.steezID = data.steezID;
      this.transactionID = data.transactionID;
    }

    validate() {
      if (!this.id || !this.galleryID || !this.investorID || !this.purchaseDate || !this.returnOnInvestment || !this.royaltiesCollected || !this.steezID || !this.transactionID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('galleries').doc(id).get();
      if (!doc.exists) {
        throw new Error('Gallery not found');
      }
      return new Gallery({ id: doc.id, ...doc.data() });
    }

    static async fetchByInvestorID(investorID) {
      if (!investorID) {
        throw new Error('Missing investorID');
      }
      const snapshot = await db.collection('galleries').where('investorID', '==', investorID).get();
      if (snapshot.empty) {
        throw new Error('No matching galleries found');
      }
      return snapshot.docs.map(doc => new Gallery({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('galleries').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('galleries').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('galleries').doc(this.id).delete();
    }
}

module.exports = Gallery;