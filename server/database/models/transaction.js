const db = require('../../../firebase-config');

class Transaction {
    constructor(id, buyPrice, buyerID, buyAmount, sellerID, buyDate, steezID, type, transactionID, status) {
      this.id = id;
      this.buyPrice = buyPrice;
      this.buyerID = buyerID;
      this.buyAmount = buyAmount;
      this.sellerID = sellerID;
      this.buyDate = buyDate;
      this.steezID = steezID;
      this.type = type;
      this.transactionID = transactionID;
      this.status = status;
    }
  
    async save() {
      await db.collection('transaction').doc(this.id).set({
        buyPrice: this.buyPrice,
        buyerID: this.buyerID,
        buyAmount: this.buyAmount,
        sellerID: this.sellerID,
        buyDate: this.buyDate,
        steezID: this.steezID,
        type: this.type,
        transactionID: this.transactionID,
        status: this.status,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('transaction').doc(id).get();
      if (!doc.exists) {
        throw new Error('Transaction not found');
      }
      return new Transaction(doc.id, doc.data().buyPrice, doc.data().buyerID, doc.data().buyAmount, doc.data().sellerID,
        doc.data().buyDate, doc.data().steezID, doc.data().type, doc.data().transactionID, doc.data().status);
    }
  
    async update(updateData) {
      await db.collection('transaction').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('transaction').doc(this.id).delete();
    }
}

module.exports = Transaction;