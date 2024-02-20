const db = require('../../../firebase-config');

class Deposit {
    constructor(id, depositAmount, depositDate, depositID, address, method, profileID, fee) {
      this.id = id;
      this.address = address;
      this.depositAmount = depositAmount;
      this.depositDate = depositDate;
      this.depositID = depositID;
      this.fee = fee;
      this.method = method;
      this.profileID = profileID;
    }
  
    async save() {
      await db.collection('deposits').doc(this.id).set({
        depositAmount: this.depositAmount,
        depositDate: this.depositDate,
        depositID: this.depositID,
        address: this.address,
        method: this.method,
        profileID: this.profileID,
        fee: this.fee,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('deposits').doc(id).get();
      if (!doc.exists) {
        throw new Error('Deposit not found');
      }
      return new Deposit(doc.id, doc.data());
    }
  
    async update(data) {
        await db.collection('deposits').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('deposits').doc(this.id).delete();
    }
}

module.exports = Deposit;