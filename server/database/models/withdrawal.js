const db = require('../../../firebase-config');

class Withdrawal {
    constructor(id, withdrawalID, address, withdrawalDate, method, withdrawalAmount, profileID, fee) {
      this.id = id;
      this.address = address;
      this.fee = fee;
      this.method = method;
      this.profileID = profileID;
      this.withdrawalAmount = withdrawalAmount;
      this.withdrawalDate = withdrawalDate;
      this.withdrawalID = withdrawalID;
    }
  
    async save() {
      await db.collection('withdrawals').doc(this.id).set({
        withdrawalID: this.withdrawalID,
        address: this.address,
        withdrawalDate: this.withdrawalDate,
        method: this.method,
        withdrawalAmount: this.withdrawalAmount,
        profileID: this.profileID,
        fee: this.fee
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('withdrawals').doc(id).get();
      if (!doc.exists) {
        throw new Error('Withdrawal not found');
      }
      return new Withdrawal(doc.id, doc.data().withdrawalID, doc.data().address, doc.data().withdrawalDate,
        doc.data().method, doc.data().withdrawalAmount, doc.data().profileID, doc.data().fee);
    }
  
    async update(updateData) {
      await db.collection('withdrawals').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('withdrawals').doc(this.id).delete();
    }
}

module.exports = Withdrawal;