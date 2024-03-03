const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Friend {
    constructor(data) {
      this.id = data.id;
      this.receiverID = data.receiverID;
      this.friendID = data.friendID;
      this.receiverFollowID = data.receiverFollowID;
      this.profileID = data.profileID;
      this.privacy = data.privacy;
      this.followerID = data.followerID;
      this.friendDate = data.friendDate;
    }

    validate() {
      if (!this.id || !this.receiverID || !this.friendID || !this.receiverFollowID || !this.profileID || !this.privacy || !this.followerID || !this.friendDate) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('friends').doc(id).get();
      if (!doc.exists) {
        throw new Error('Friend not found');
      }
      return new Friend({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('friends').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching friends found');
      }
      return snapshot.docs.map(doc => new Friend({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('friends').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('friends').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('friends').doc(this.id).delete();
    }
}

module.exports = Friend;