const db = require('../../../firebase-config');

class Vote {
    constructor(data) {
      this.id = data.id;
      this.rewardShare = data.rewardShare;
      this.voteTime = data.voteTime;
      this.sipID = data.sipID;
      this.hasVoted = data.hasVoted;
      this.profileID = data.profileID;
      this.stakingID = data.stakingID;
      this.rewardPool = data.rewardPool;
      this.voteWeight = data.voteWeight;
      this.voterType = data.voterType;
      this.voteID = data.voteID;
    }

    validate() {
      if (!this.id || !this.rewardShare || !this.voteTime || !this.sipID || this.hasVoted === undefined || !this.profileID || !this.stakingID || !this.rewardPool || !this.voteWeight || !this.voterType || !this.voteID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('vote').doc(id).get();
      if (!doc.exists) {
        throw new Error('Vote not found');
      }
      return new Vote({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('vote').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching votes found');
      }
      return snapshot.docs.map(doc => new Vote({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('vote').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('vote').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('vote').doc(this.id).delete();
    }
}

module.exports = Vote;