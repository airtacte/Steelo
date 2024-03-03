const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Creator {
    constructor(data) {
      this.id = data.id;
      this.artForm = data.artForm;
      this.communityType = data.communityType;
      this.creatorID = data.creatorID;
      this.genre = data.genre;
      this.profileID = data.profileID;
      this.steezID = data.steezID;
    }

    validate() {
      if (!this.id || !this.artForm || !this.communityType || !this.creatorID || !this.profileID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('creators').doc(id).get();
      if (!doc.exists) {
        throw new Error('Creator not found');
      }
      return new Creator({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('creators').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching creators found');
      }
      return snapshot.docs.map(doc => new Creator({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('creators').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('creators').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('creators').doc(this.id).delete();
    }
}

module.exports = Creator;