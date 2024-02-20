const db = require('../../../firebase-config');

class Follower {
    constructor(id, profileID, followDate, followeeID, followerID) {
      this.id = id;
      this.followDate = followDate;
      this.followeeID = followeeID;
      this.followerID = followerID;
      this.profileID = profileID;
    }
  
    async save() {
      await db.collection('followers').doc(this.id).set({
        profileID: this.profileID,
        followDate: this.followDate,
        followeeID: this.followeeID,
        followerID: this.followerID,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('followers').doc(id).get();
      if (!doc.exists) {
        throw new Error('Follower not found');
      }
      return new Follower(doc.id, doc.data());
    }
  
    async update(data) {
        await db.collection('followers').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('followers').doc(this.id).delete();
    }
}

module.exports = Follower;  