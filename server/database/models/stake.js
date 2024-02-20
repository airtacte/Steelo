const db = require('../../../firebase-config');

class Stake {
    constructor(id, stakeDate, stakeAmount, stakeID, profileID, yieldRate, steeloID, stakeDuration) {
      this.id = id;
      this.stakeDate = stakeDate;
      this.stakeAmount = stakeAmount;
      this.stakeID = stakeID;
      this.profileID = profileID;
      this.yieldRate = yieldRate;
      this.steeloID = steeloID;
      this.stakeDuration = stakeDuration;
    }
  
    async save() {
      await db.collection('stakes').doc(this.id).set({
        stakeDate: this.stakeDate,
        stakeAmount: this.stakeAmount,
        stakeID: this.stakeID,
        profileID: this.profileID,
        yieldRate: this.yieldRate,
        steeloID: this.steeloID,
        stakeDuration: this.stakeDuration
      });
    }
  
    async update(data) {
        await db.collection('stakes').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('stakes').doc(this.id).delete();
    }
}

module.exports = Stake;  