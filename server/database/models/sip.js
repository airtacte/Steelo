const db = require('../../../firebase-config');

class SIP {
    constructor(id, duration, sipID, isVoteSuccess, sipRules, executionDeadline, initiator, executionDetails, description, startTime, sipVotes, executionConfirmation, sipType) {
      this.id = id;
      this.duration = duration;
      this.sipID = sipID;
      this.isVoteSuccess = isVoteSuccess;
      this.sipRules = sipRules;
      this.executionDeadline = executionDeadline;
      this.initiator = initiator;
      this.executionDetails = executionDetails;
      this.description = description;
      this.startTime = startTime;
      this.sipVotes = sipVotes;
      this.executionConfirmation = executionConfirmation;
      this.sipType = sipType;
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
        sipType: this.sipType
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