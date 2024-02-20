const db = require('../../../firebase-config');

class Steez {
    constructor(id, steezAmount, royaltiesGenerated, hasSoldInvestment, preOrderPrice, ownerHistory, creatorID, currentPrice, sellPrice, sellDate, transactionCount) {
      this.id = id;
      this.creatorID = creatorID;
      this.currentPrice = currentPrice;
      this.hasSoldInvestment = hasSoldInvestment;
      this.ownerHistory = ownerHistory;
      this.preOrderPrice = preOrderPrice;
      this.royaltiesGenerated = royaltiesGenerated;
      this.sellPrice = sellPrice;
      this.sellDate = sellDate;
      this.steezAmount = steezAmount;
      this.steezID = steezID;
      this.transactionCount = transactionCount;
    }
  
    async save() {
      await db.collection('steez').doc(this.id).set({
        creatorID: this.creatorID,
        currentPrice: this.currentPrice,
        hasSoldInvestment: this.hasSoldInvestment,
        ownerHistory: this.ownerHistory,
        preOrderPrice: this.preOrderPrice,
        royaltiesGenerated: this.royaltiesGenerated,
        sellPrice: this.sellPrice,
        sellDate: this.sellDate,
        steezAmount: this.steezAmount,
        steezID: this.steezID,
        transactionCount: this.transactionCount,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('steez').doc(id).get();
      if (!doc.exists) {
        throw new Error('Steez not found');
      }
      return new Steez(doc.id, doc.data().steezAmount, doc.data().royaltiesGenerated, doc.data().hasSoldInvestment,
        doc.data().preOrderPrice, doc.data().ownerHistory, doc.data().creatorID, doc.data().currentPrice,
        doc.data().sellPrice, doc.data().sellDate, doc.data().transactionCount);
    }
  
    async update(updateData) {
      await db.collection('steez').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('steez').doc(this.id).delete();
    }
}

module.exports = Steez;