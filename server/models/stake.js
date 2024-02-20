const db = require('../../../firebase-config');

class Stake {
    constructor(data) {
      this.id = data.id;
      this.stakeDate = data.stakeDate;
      this.stakeAmount = data.stakeAmount;
      this.stakeID = data.stakeID;
      this.profileID = data.profileID;
      this.yieldRate = data.yieldRate;
      this.steeloID = data.steeloID;
      this.stakeDuration = data.stakeDuration;
    }

    validate() {
      if (!this.id || !this.stakeDate || !this.stakeAmount || !this.stakeID || !this.profileID || !this.yieldRate || !this.steeloID || !this.stakeDuration) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('stakes').doc(id).get();
      if (!doc.exists) {
        throw new Error('Stake not found');
      }
      return new Stake({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('stakes').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching stakes found');
      }
      return snapshot.docs.map(doc => new Stake({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('stakes').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('stakes').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('stakes').doc(this.id).delete();
    }
}

module.exports = Stake;