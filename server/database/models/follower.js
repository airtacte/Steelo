const db = require('../../../firebase-config');

class Follower {
    constructor(data) {
      this.id = data.id;
      this.followDate = data.followDate;
      this.followeeID = data.followeeID;
      this.followerID = data.followerID;
      this.profileID = data.profileID;
    }

    validate() {
      if (!this.id || !this.followDate || !this.followeeID || !this.followerID || !this.profileID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('followers').doc(id).get();
      if (!doc.exists) {
        throw new Error('Follower not found');
      }
      return new Follower({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('followers').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching followers found');
      }
      return snapshot.docs.map(doc => new Follower({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('followers').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('followers').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('followers').doc(this.id).delete();
    }
}

module.exports = Follower;