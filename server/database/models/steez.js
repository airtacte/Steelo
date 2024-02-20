const db = require('../../../firebase-config');

class Steez {
    constructor(id, steezAmount, royaltiesGenerated, hasSoldInvestment, preOrderPrice, ownerHistory, creatorID, currentPrice, sellPrice, sellDate, transactionCount) {
      this.id = id;
      this.steezAmount = steezAmount;
      this.royaltiesGenerated = royaltiesGenerated;
      this.hasSoldInvestment = hasSoldInvestment;
      this.preOrderPrice = preOrderPrice;
      this.ownerHistory = ownerHistory;
      this.creatorID = creatorID;
      this.currentPrice = currentPrice;
      this.sellPrice = sellPrice;
      this.sellDate = sellDate;
      this.transactionCount = transactionCount;
    }
  
    async save() {
      await db.collection('steez').doc(this.id).set({
        steezAmount: this.steezAmount,
        royaltiesGenerated: this.royaltiesGenerated,
        hasSoldInvestment: this.hasSoldInvestment,
        preOrderPrice: this.preOrderPrice,
        ownerHistory: this.ownerHistory,
        creatorID: this.creatorID,
        currentPrice: this.currentPrice,
        sellPrice: this.sellPrice,
        sellDate: this.sellDate,
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