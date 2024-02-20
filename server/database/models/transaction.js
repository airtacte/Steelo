const db = require('../../../firebase-config');

class Transaction {
    constructor(id, buyPrice, buyerID, buyAmount, sellerID, buyDate, steezID, type, transactionID, status) {
      this.id = id;
      this.buyAmount = buyAmount;
      this.buyDate = buyDate;
      this.buyPrice = buyPrice;
      this.buyerID = buyerID;
      this.sellerID = sellerID;
      this.status = status;
      this.steezID = steezID;
      this.steeloID = steeloID;
      this.transactionID = transactionID;
      this.type = type;
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