const db = require('../../../firebase-config');

class Vote {
    constructor(id, rewardShare, voteTime, sipID, hasVoted, profileID, stakingID, rewardPool, voteWeight, voterType, voteID) {
      this.id = id;
      this.rewardShare = rewardShare;
      this.voteTime = voteTime;
      this.sipID = sipID;
      this.hasVoted = hasVoted;
      this.profileID = profileID;
      this.stakingID = stakingID;
      this.rewardPool = rewardPool;
      this.voteWeight = voteWeight;
      this.voterType = voterType;
      this.voteID = voteID;
    }
  
    async save() {
      await db.collection('vote').doc(this.id).set({
        rewardShare: this.rewardShare,
        voteTime: this.voteTime,
        sipID: this.sipID,
        hasVoted: this.hasVoted,
        profileID: this.profileID,
        stakingID: this.stakingID,
        rewardPool: this.rewardPool,
        voteWeight: this.voteWeight,
        voterType: this.voterType,
        voteID: this.voteID,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('vote').doc(id).get();
      if (!doc.exists) {
        throw new Error('Vote not found');
      }
      return new Vote(doc.id, doc.data().rewardShare, doc.data().voteTime, doc.data().sipID, doc.data().hasVoted,
        doc.data().profileID, doc.data().stakingID, doc.data().rewardPool, doc.data().voteWeight,
        doc.data().voterType, doc.data().voteID);
    }
  
    async update(updateData) {
      await db.collection('vote').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('vote').doc(this.id).delete();
    }
}

module.exports = Vote;