const db = require('../../../firebase-config');

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
  
    static async fetchById(id) {
      const doc = await db.collection('contents').doc(id).get();
      if (!doc.exists) {
        throw new Error('Content not found');
      }
      return new Content({ id: doc.id, ...doc.data() });
    }
  
    async save() {
      await db.collection('contents').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      await db.collection('contents').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('contents').doc(this.id).delete();
    }
}

module.exports = Content;