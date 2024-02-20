const db = require('../../../firebase-config');

class Space {
    constructor(id, spaceID, contributorID, likeID, contentID, commentID, rank) {
      this.id = id;
      this.spaceID = spaceID;
      this.contributorID = contributorID;
      this.likeID = likeID;
      this.contentID = contentID;
      this.commentID = commentID;
      this.rank = rank;
    }
  
    async save() {
      await db.collection('spaces').doc(this.id).set({
        spaceID: this.spaceID,
        contributorID: this.contributorID,
        likeID: this.likeID,
        contentID: this.contentID,
        commentID: this.commentID,
        rank: this.rank
      });
    }
  
    async update(data) {
        await db.collection('spaces').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('spaces').doc(this.id).delete();
    }
}
  
module.exports = Space;  