const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Withdrawal {
    constructor(data) {
      this.id = data.id;
      this.withdrawalID = data.withdrawalID;
      this.address = data.address;
      this.withdrawalDate = data.withdrawalDate;
      this.method = data.method;
      this.withdrawalAmount = data.withdrawalAmount;
      this.profileID = data.profileID;
      this.fee = data.fee;
    }

    validate() {
      if (!this.id || !this.withdrawalID || !this.address || !this.withdrawalDate || !this.method || !this.withdrawalAmount || !this.profileID || !this.fee) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('withdrawals').doc(id).get();
      if (!doc.exists) {
        throw new Error('Withdrawal not found');
      }
      return new Withdrawal({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('withdrawals').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching withdrawals found');
      }
      return snapshot.docs.map(doc => new Withdrawal({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('withdrawals').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('withdrawals').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('withdrawals').doc(this.id).delete();
    }
}

module.exports = Withdrawal;