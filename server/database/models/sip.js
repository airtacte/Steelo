const db = require('../../../firebase-config');

class SIP {
    constructor(id, duration, sipID, isVoteSuccess, sipRules, executionDeadline, initiator, executionDetails, description, startTime, sipVotes, executionConfirmation, sipType) {
      this.id = id;
      this.description = description;
      this.duration = duration;
      this.executionConfirmation = executionConfirmation;
      this.executionDeadline = executionDeadline;
      this.executionDetails = executionDetails;
      this.initiator = initiator;
      this.isVoteSuccess = isVoteSuccess;
      this.sipID = sipID;
      this.sipRules = sipRules;
      this.sipType = sipType;
      this.sipVotes = sipVotes;
      this.startTime = startTime;
    }
  
    async save() {
      await db.collection('sips').doc(this.id).set({
        duration: this.duration,
        sipID: this.sipID,
        isVoteSuccess: this.isVoteSuccess,
        sipRules: this.sipRules,
        executionDeadline: this.executionDeadline,
        initiator: this.initiator,
        executionDetails: this.executionDetails,
        description: this.description,
        startTime: this.startTime,
        sipVotes: this.sipVotes,
        executionConfirmation: this.executionConfirmation,
        sipType: this.sipType,
      });
    }
  
    async update(data) {
        await db.collection('sips').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('sips').doc(this.id).delete();
    }
}

module.exports = SIP;  