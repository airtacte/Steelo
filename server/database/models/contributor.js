const db = require('../../../firebase-config');

class Contributor {
    constructor(id, role, contributorID, genre, collectRoyalty, contentID, creatorID, type) {
      this.id = id;
      this.collectRoyalty = collectRoyalty;
      this.contentID = contentID;
      this.contributorID = contributorID;
      this.creatorID = creatorID;
      this.genre = genre;
      this.role = role;
      this.type = type;
    }
  
    async save() {
      await db.collection('contributors').doc(this.id).set({
        role: this.role,
        contributorID: this.contributorID,
        genre: this.genre,
        collectRoyalty: this.collectRoyalty,
        contentID: this.contentID,
        creatorID: this.creatorID,
        type: this.type,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('contributors').doc(id).get();
      if (!doc.exists) {
        throw new Error('Contributor not found');
      }
      return new Contributor(doc.id, doc.data().role, doc.data().contributorID, doc.data().genre,
        doc.data().collectRoyalty, doc.data().contentID, doc.data().creatorID, doc.data().type);
    }
  
    async update(updateData) {
      await db.collection('contributors').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('contributors').doc(this.id).delete();
    }
}

module.exports = Contributor;  