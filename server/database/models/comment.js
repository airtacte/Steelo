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

    validate() {
      if (!this.id || !this.comment || !this.commentDate || !this.contentID || !this.profileID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('comments').doc(id).get();
      if (!doc.exists) {
        throw new Error('Comment not found');
      }
      return new Comment({ id: doc.id, ...doc.data() });
    }

    static async fetchByContentID(contentID) {
      if (!contentID) {
        throw new Error('Missing contentID');
      }
      const snapshot = await db.collection('comments').where('contentID', '==', contentID).get();
      if (snapshot.empty) {
        throw new Error('No matching comments found');
      }
      return snapshot.docs.map(doc => new Comment({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('comments').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('comments').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('comments').doc(this.id).delete();
    }
}

module.exports = Comment;