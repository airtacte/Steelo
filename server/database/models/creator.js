const db = require('../../../firebase-config');

class Creator {
    constructor(data) {
      this.id = data.id;
      this.communityType = data.communityType;
      this.profileID = data.profileID;
      this.creatorID = data.creatorID;
      this.genre = data.genre;
      this.steezID = data.steezID;
      this.artForm = data.artForm;
    }
  
    static async fetchById(id) {
      const doc = await db.collection('creators').doc(id).get();
      if (!doc.exists) {
        throw new Error('Creator not found');
      }
      return new Creator({ id: doc.id, ...doc.data() });
    }
  
    async save() {
      await db.collection('creators').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      await db.collection('creators').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('creators').doc(this.id).delete();
    }
}

module.exports = Creator;