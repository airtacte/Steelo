const db = require('../../../firebase-config');

class Like {
    constructor(id, profileID, contentID, likeDate, likeSpeed) {
      this.id = id;
      this.contentID = contentID;
      this.likeDate = likeDate;
      this.likeID = likeID;
      this.likeSpeed = likeSpeed;
      this.profileID = profileID;
    }
  
    async save() {
      await db.collection('likes').doc(this.id).set({
        profileID: this.profileID,
        contentID: this.contentID,
        likeDate: this.likeDate,
        likeSpeed: this.likeSpeed,
      });
    }
  
    async update(data) {
        await db.collection('likes').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('likes').doc(this.id).delete();
    }
}

module.exports = Like;  