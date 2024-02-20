const db = require('../../../firebase-config');

class Content {
    constructor(data) {
      this.id = data.id;
      this.spaceRank = data.spaceRank;
      this.spaceID = data.spaceID;
      this.contentURI = data.contentURI;
      this.contentID = data.contentID;
      this.inSpace = data.inSpace;
      this.creatorID = data.creatorID;
      this.exclusive = data.exclusive;
      this.viewCount = data.viewCount;
      this.category = data.category;
      this.postedDate = data.postedDate;
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