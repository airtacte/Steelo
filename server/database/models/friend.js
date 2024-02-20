const db = require('../../../firebase-config');

class Friend {
    constructor(id, receiverID, friendID, receiverFollowID, profileID, privacy, followerID, friendDate) {
      this.id = id;
      this.followerID = followerID;
      this.friendDate = friendDate;
      this.friendID = friendID;
      this.privacy = privacy;
      this.profileID = profileID;
      this.receiverFollowID = receiverFollowID;
      this.receiverID = receiverID;
    }
  
    async save() {
      await db.collection('friends').doc(this.id).set({
        receiverID: this.receiverID,
        friendID: this.friendID,
        receiverFollowID: this.receiverFollowID,
        profileID: this.profileID,
        privacy: this.privacy,
        followerID: this.followerID,
        friendDate: this.friendDate,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('friends').doc(id).get();
      if (!doc.exists) {
        throw new Error('Friend not found');
      }
      return new Friend(doc.id, doc.data());
    }
  
    async update(data) {
        await db.collection('friends').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('friends').doc(this.id).delete();
    }
}

module.exports = Friend;  