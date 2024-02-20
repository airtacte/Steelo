const db = require('../../../firebase-config');

class Comment {
    constructor(data) {
      this.id = data.id;
      this.comment = data.comment;
      this.commentDate = data.commentDate;
      this.commentID = data.commentID;
      this.contentID = data.contentID;
      this.isReply = data.isReply;
      this.profileID = data.profileID;
      this.replyID = data.replyID;
    }
  
    static async fetchById(id) {
      const doc = await db.collection('comments').doc(id).get();
      if (!doc.exists) {
        throw new Error('Comment not found');
      }
      return new Comment({ id: doc.id, ...doc.data() });
    }
  
    async save() {
      await db.collection('comments').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      await db.collection('comments').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('comments').doc(this.id).delete();
    }
}

module.exports = Comment;  