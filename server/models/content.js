const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Content {
    constructor(data) {
      this.id = data.id;
      this.category = data.category;
      this.contentID = data.contentID;
      this.contentURI = data.contentURI;
      this.creatorID = data.creatorID;
      this.exclusive = data.exclusive;
      this.inSpace = data.inSpace;
      this.postedDate = data.postedDate;
      this.spaceID = data.spaceID;
      this.spaceRank = data.spaceRank;
      this.viewCount = data.viewCount;
    }

    validate() {
      if (!this.id || !this.category || !this.contentID || !this.contentURI || !this.creatorID || !this.postedDate) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('contents').doc(id).get();
      if (!doc.exists) {
        throw new Error('Content not found');
      }
      return new Content({ id: doc.id, ...doc.data() });
    }

    static async fetchByCreatorID(creatorID) {
      if (!creatorID) {
        throw new Error('Missing creatorID');
      }
      const snapshot = await db.collection('contents').where('creatorID', '==', creatorID).get();
      if (snapshot.empty) {
        throw new Error('No matching contents found');
      }
      return snapshot.docs.map(doc => new Content({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('contents').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('contents').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('contents').doc(this.id).delete();
    }
}

module.exports = Content;