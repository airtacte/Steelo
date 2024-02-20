const db = require('../../../firebase-config');

class Trade {
    constructor(id, buyPrice, profileID, buyDate, steezID, tradeID, tradeType, status) {
      this.id = id;
      this.buyDate = buyDate;
      this.buyPrice = buyPrice;
      this.profileID = profileID;
      this.status = status;
      this.steezID = steezID;
      this.tradeID = tradeID;
      this.tradeType = tradeType;
    }
  
    async save() {
      await db.collection('trade').doc(this.id).set({
        buyPrice: this.buyPrice,
        profileID: this.profileID,
        buyDate: this.buyDate,
        steezID: this.steezID,
        tradeID: this.tradeID,
        tradeType: this.tradeType,
        status: this.status,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('trade').doc(id).get();
      if (!doc.exists) {
        throw new Error('Trade not found');
      }
      return new Trade(doc.id, doc.data().buyPrice, doc.data().profileID, doc.data().buyDate, doc.data().steezID,
        doc.data().tradeID, doc.data().tradeType, doc.data().status);
    }
  
    async update(updateData) {
      await db.collection('trade').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('trade').doc(this.id).delete();
    }
}

module.exports = Trade;