const db = require('../../../firebase-config');

class Village {
    constructor(id, buyPrice, royaltiesCollected, culture, buyDate, genre, investorID, purchaseOrigin, steezID, type, villageID) {
      this.id = id;
      this.buyDate = buyDate;
      this.buyPrice = buyPrice;
      this.culture = culture;
      this.genre = genre;
      this.investorID = investorID;
      this.purchaseOrigin = purchaseOrigin;
      this.royaltiesCollected = royaltiesCollected;
      this.steezID = steezID;
      this.type = type;
      this.villageID = villageID;
    }
  
    async save() {
      await db.collection('village').doc(this.id).set({
        buyPrice: this.buyPrice,
        royaltiesCollected: this.royaltiesCollected,
        culture: this.culture,
        buyDate: this.buyDate,
        genre: this.genre,
        investorID: this.investorID,
        purchaseOrigin: this.purchaseOrigin,
        steezID: this.steezID,
        type: this.type,
        villageID: this.villageID,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('village').doc(id).get();
      if (!doc.exists) {
        throw new Error('Village not found');
      }
      return new Village(doc.id, doc.data().buyPrice, doc.data().royaltiesCollected, doc.data().culture,
        doc.data().buyDate, doc.data().genre, doc.data().investorID, doc.data().purchaseOrigin,
        doc.data().steezID, doc.data().type, doc.data().villageID);
    }
  
    async update(updateData) {
      await db.collection('village').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('village').doc(this.id).delete();
    }
}

module.exports = Village;