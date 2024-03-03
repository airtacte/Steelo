const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class History {
    constructor(data) {
      this.id = data.id;
      this.feedback = data.feedback;
      this.browseDate = data.browseDate;
      this.viewingTime = data.viewingTime;
      this.historyID = data.historyID;
      this.profileID = data.profileID;
      this.creatorID = data.creatorID;
    }

    validate() {
      if (!this.id || !this.feedback || !this.browseDate || !this.viewingTime || !this.historyID || !this.profileID || !this.creatorID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('histories').doc(id).get();
      if (!doc.exists) {
        throw new Error('History not found');
      }
      return new History({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('histories').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching histories found');
      }
      return snapshot.docs.map(doc => new History({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('histories').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('histories').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('histories').doc(this.id).delete();
    }
}

module.exports = History;