const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Space {
    constructor(data) {
      this.id = data.id;
      this.commentID = data.commentID;
      this.contentID = data.contentID;
      this.contributorID = data.contributorID;
      this.likeID = data.likeID;
      this.rank = data.rank;
      this.spaceID = data.spaceID;
    }

    validate() {
      if (!this.id || !this.commentID || !this.contentID || !this.contributorID || !this.likeID || !this.rank || !this.spaceID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('spaces').doc(id).get();
      if (!doc.exists) {
        throw new Error('Space not found');
      }
      return new Space({ id: doc.id, ...doc.data() });
    }

    static async fetchByContributorID(contributorID) {
      if (!contributorID) {
        throw new Error('Missing contributorID');
      }
      const snapshot = await db.collection('spaces').where('contributorID', '==', contributorID).get();
      if (snapshot.empty) {
        throw new Error('No matching spaces found');
      }
      return snapshot.docs.map(doc => new Space({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('spaces').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('spaces').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('spaces').doc(this.id).delete();
    }
}

module.exports = Space;