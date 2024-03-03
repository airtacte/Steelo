const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class SIP {
    constructor(data) {
      this.id = data.id;
      this.description = data.description;
      this.duration = data.duration;
      this.executionConfirmation = data.executionConfirmation;
      this.executionDeadline = data.executionDeadline;
      this.executionDetails = data.executionDetails;
      this.initiator = data.initiator;
      this.isVoteSuccess = data.isVoteSuccess;
      this.sipID = data.sipID;
      this.sipRules = data.sipRules;
      this.sipType = data.sipType;
      this.sipVotes = data.sipVotes;
      this.startTime = data.startTime;
    }

    validate() {
      if (!this.id || !this.description || !this.duration || !this.executionConfirmation || !this.executionDeadline || !this.executionDetails || !this.initiator || !this.isVoteSuccess || !this.sipID || !this.sipRules || !this.sipType || !this.sipVotes || !this.startTime) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('sips').doc(id).get();
      if (!doc.exists) {
        throw new Error('SIP not found');
      }
      return new SIP({ id: doc.id, ...doc.data() });
    }

    static async fetchByInitiator(initiator) {
      if (!initiator) {
        throw new Error('Missing initiator');
      }
      const snapshot = await db.collection('sips').where('initiator', '==', initiator).get();
      if (snapshot.empty) {
        throw new Error('No matching SIPs found');
      }
      return snapshot.docs.map(doc => new SIP({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('sips').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('sips').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('sips').doc(this.id).delete();
    }
}

module.exports = SIP;