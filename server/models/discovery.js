const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Discovery {
    constructor(data) {
      this.id = data.id;
      this.creatorID = data.creatorID;
      this.discoveryDate = data.discoveryDate;
      this.origin = data.origin;
      this.profileID = data.profileID;
      this.result = data.result;
    }

    validate() {
      if (!this.id || !this.creatorID || !this.discoveryDate || !this.origin || !this.profileID || !this.result) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('discoveries').doc(id).get();
      if (!doc.exists) {
        throw new Error('Discovery not found');
      }
      return new Discovery({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('discoveries').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching discoveries found');
      }
      return snapshot.docs.map(doc => new Discovery({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('discoveries').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('discoveries').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('discoveries').doc(this.id).delete();
    }
}

module.exports = Discovery;