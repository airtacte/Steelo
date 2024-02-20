const db = require('../../../firebase-config');

class Deposit {
    constructor(data) {
      this.id = data.id;
      this.address = data.address;
      this.depositAmount = data.depositAmount;
      this.depositDate = data.depositDate;
      this.depositID = data.depositID;
      this.fee = data.fee;
      this.method = data.method;
      this.profileID = data.profileID;
    }

    validate() {
      if (!this.id || !this.address || !this.depositAmount || !this.depositDate || !this.method || !this.profileID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('deposits').doc(id).get();
      if (!doc.exists) {
        throw new Error('Deposit not found');
      }
      return new Deposit({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('deposits').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching deposits found');
      }
      return snapshot.docs.map(doc => new Deposit({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('deposits').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('deposits').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('deposits').doc(this.id).delete();
    }
}

module.exports = Deposit;