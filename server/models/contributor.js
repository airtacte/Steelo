const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Contributor {
    constructor(data) {
      this.id = data.id;
      this.role = data.role;
      this.contributorID = data.contributorID;
      this.genre = data.genre;
      this.collectRoyalty = data.collectRoyalty;
      this.contentID = data.contentID;
      this.creatorID = data.creatorID;
      this.type = data.type;
    }

    validate() {
      if (!this.id || !this.role || !this.contributorID || !this.contentID || !this.creatorID || !this.type) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('contributors').doc(id).get();
      if (!doc.exists) {
        throw new Error('Contributor not found');
      }
      return new Contributor({ id: doc.id, ...doc.data() });
    }

    static async fetchByContentID(contentID) {
      if (!contentID) {
        throw new Error('Missing contentID');
      }
      const snapshot = await db.collection('contributors').where('contentID', '==', contentID).get();
      if (snapshot.empty) {
        throw new Error('No matching contributors found');
      }
      return snapshot.docs.map(doc => new Contributor({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('contributors').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('contributors').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('contributors').doc(this.id).delete();
    }
}

module.exports = Contributor;