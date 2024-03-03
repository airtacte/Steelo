const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Collect {
    constructor(data) {
      this.id = data.id;
      this.collectID = data.collectID;
      this.collectionDate = data.collectionDate;
      this.contentID = data.contentID;
      this.profileID = data.profileID;
    }
  
    static async fetchById(id) {
      const doc = await db.collection('collects').doc(id).get();
      if (!doc.exists) {
        throw new Error('Collect not found');
      }
      return new Collect({ id: doc.id, ...doc.data() });
    }
  
    static async fetchByProfileId(profileID) {
      const snapshot = await db.collection('collects').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No collects found for this profile');
      }
      return snapshot.docs.map(doc => new Collect({ id: doc.id, ...doc.data() }));
    }

    static async fetchByContentId(contentID) {
      const snapshot = await db.collection('collects').where('contentID', '==', contentID).get();
      if (snapshot.empty) {
        throw new Error('No collects found for this content');
      }
      return snapshot.docs.map(doc => new Collect({ id: doc.id, ...doc.data() }));
    }

    async save() {
      if (!this.profileID || !this.contentID) {
        throw new Error('ProfileID and ContentID are required');
      }
      // Perform any additional validation as necessary...

      try {
        await db.collection('collects').doc(this.id).set({ ...this });
      } catch (error) {
        throw new Error('Failed to save collect: ' + error.message);
      }
    }
  
    async update(updateData) {
      await db.collection('collects').doc(this.id).update(updateData);
    }
    
  
    async delete() {
      await db.collection('collects').doc(this.id).delete();
    }
}

module.exports = Collect;  